#!/usr/bin/env bash
# split-by-headers.sh
#
# Splits a markdown file into a chapter/item tree:
#   <output_dir>/<source_basename>/
#     01_<chapter_slug>/
#       01_<item_slug>.md   (body starts with "## Item Title")
#       02_<item_slug>.md
#     02_<chapter_slug>/
#       ...
#
# Chapter  = a real (non-fenced) line matching ^# \s  (H1)
# Item     = a real (non-fenced) line matching ^## \s (H2), nested under the
#            current chapter. Deeper headers (###-######) are treated as part
#            of the item's content, not new boundaries.
# Syllabus = the FIRST H1 in the file, IF its title contains "syllabus"
#            (case-insensitive). That whole H1 block (down to the next H1)
#            is dropped entirely - not numbered, not kept anywhere. If the
#            first H1 does not match "syllabus", it is treated as chapter 01
#            and nothing is dropped.
# Fences   = ``` toggles fence state. Any # / ## line seen while inside a
#            fence is content, never a boundary. Handles fenced code blocks
#            containing shell comments like "# Install ..." that would
#            otherwise be misread as headers.
#
# Usage:
#   ./split-by-headers.sh SOURCE.md [OUTPUT_DIR] [--dry-run] [--no-subfolder]
#
# OUTPUT_DIR defaults to the current directory. By default the tree is
# created at OUTPUT_DIR/<source_basename_without_ext>/ (one subfolder named
# after the source). Pass --no-subfolder to write chapter folders directly
# into OUTPUT_DIR instead - useful when the caller has already created and
# named an appropriate folder itself (e.g. a wrapper script that made a
# folder for the original file and wants chapters written straight into it,
# not into a redundant extra basename-named layer inside it).
#
# --dry-run: runs the full parse (fence tracking, syllabus detection,
# chapter/item boundaries) but writes nothing to disk - no folders, no
# files. Instead prints the chapter/item tree it WOULD create, with each
# item's line count, so you can sanity-check a source file's structure
# before committing to a real run.

set -euo pipefail

DRY_RUN=false
NO_SUBFOLDER=false
SOURCE=""
OUT_ROOT="."
pos=()
for arg in "$@"; do
  case "$arg" in
  --dry-run) DRY_RUN=true ;;
  --no-subfolder) NO_SUBFOLDER=true ;;
  *) pos+=("$arg") ;;
  esac
done

if [[ ${#pos[@]} -lt 1 ]]; then
  echo "Usage: $0 SOURCE.md [OUTPUT_DIR] [--dry-run] [--no-subfolder]" >&2
  exit 1
fi
SOURCE="${pos[0]}"
OUT_ROOT="${pos[1]:-.}"

if [[ ! -f "$SOURCE" ]]; then
  echo "Error: source file not found: $SOURCE" >&2
  exit 1
fi

BASE="$(basename "$SOURCE")"
BASE="${BASE%.*}"
if [[ "$NO_SUBFOLDER" == true ]]; then
  BOOK_DIR="$OUT_ROOT"
else
  BOOK_DIR="$OUT_ROOT/$BASE"
fi
if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "$BOOK_DIR"
fi

# ---------- slugify: lowercase, non-alnum runs -> "_", trim leading/trailing "_" ----------
slugify() {
  local s="$1"
  s="${s,,}"
  s="$(echo "$s" | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//')"
  if [[ -z "$s" ]]; then
    s="untitled"
  fi
  echo "$s"
}

# ---------- pass 1: read the whole file into an array, one element per line ----------
mapfile -t LINES <"$SOURCE"
TOTAL=${#LINES[@]}

# ---------- pass 2: walk lines, classify each as chapter / item / content, respecting fences ----------
in_fence=false
first_h1_seen=false
skip_syllabus=false # true only while we're inside a confirmed syllabus H1 block
chapter_num=0
item_num=0
chapter_slug=""
chapter_dir=""
item_lines=() # accumulated body lines for the item currently being written
item_title=""
item_open=false

item_has_content() {
  # True if item_lines contains at least one non-blank line.
  local l
  for l in "${item_lines[@]}"; do
    if [[ -n "${l// /}" ]]; then
      return 0
    fi
  done
  return 1
}

flush_item() {
  # Writes the currently-accumulated item (if any) to disk.
  # A speculative "Overview" item (item_num=0) that ended up empty is
  # dropped instead of writing a near-blank file.
  if [[ "$item_open" == true && "$item_num" -eq 0 ]] && ! item_has_content; then
    item_lines=()
    item_open=false
    return
  fi
  if [[ "$item_open" == true ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      printf "    %02d_%s.md  (%d lines)\n" "$item_num" "$(slugify "$item_title")" "${#item_lines[@]}"
    elif [[ -n "$chapter_dir" ]]; then
      local fname
      fname=$(printf "%02d_%s.md" "$item_num" "$(slugify "$item_title")")
      {
        echo "## $item_title"
        echo
        printf '%s\n' "${item_lines[@]}"
      } >"$chapter_dir/$fname"
    fi
    item_lines=()
    item_open=false
  fi
}

start_overview_item() {
  # Called when a chapter has content before its first H2 - bucketed into
  # a 00_<chapter>_overview.md item instead of being dropped.
  item_num=0
  item_title="Overview"
  item_open=true
  item_lines=()
}

for ((i = 0; i < TOTAL; i++)); do
  line="${LINES[$i]}"

  # ---- fence toggle: a line is a fence delimiter if, ignoring leading
  # whitespace, it starts with ``` (any info-string after is irrelevant) ----
  if [[ "$line" =~ ^[[:space:]]*'```' ]]; then
    if [[ "$in_fence" == true ]]; then
      in_fence=false
    else
      in_fence=true
    fi
    if [[ "$item_open" == true ]]; then
      item_lines+=("$line")
    fi
    continue
  fi

  if [[ "$in_fence" == true ]]; then
    if [[ "$item_open" == true ]]; then
      item_lines+=("$line")
    fi
    continue
  fi

  # ---- real (non-fenced) header detection ----
  if [[ "$line" =~ ^#\ +(.*)$ ]]; then
    title="${BASH_REMATCH[1]}"

    if [[ "$first_h1_seen" == false ]]; then
      first_h1_seen=true
      if [[ "${title,,}" == *syllabus* ]]; then
        skip_syllabus=true
        continue
      fi
    elif [[ "$skip_syllabus" == true ]]; then
      # This H1 ends the syllabus block we were skipping.
      skip_syllabus=false
    fi

    # Close out whatever item/chapter came before.
    flush_item

    chapter_num=$((chapter_num + 1))
    item_num=0
    chapter_slug=$(printf "%02d_%s" "$chapter_num" "$(slugify "$title")")
    chapter_dir="$BOOK_DIR/$chapter_slug"
    if [[ "$DRY_RUN" == true ]]; then
      echo "  $chapter_slug/"
    else
      mkdir -p "$chapter_dir"
    fi

    # Speculatively open an "Overview" item in case content appears
    # before the first H2 in this chapter. If an H2 shows up first,
    # flush_item below discards this if it's still empty.
    start_overview_item
    continue
  fi

  if [[ "$skip_syllabus" == true ]]; then
    # Still inside the syllabus block (which may itself contain H2s,
    # fenced code, etc.) - discard everything until the next real H1.
    continue
  fi

  if [[ "$line" =~ ^##\ +(.*)$ ]]; then
    title="${BASH_REMATCH[1]}"
    flush_item
    item_num=$((item_num + 1))
    item_title="$title"
    item_open=true
    item_lines=()
    continue
  fi

  # ---- ordinary content line (includes ### - ###### subheaders, which
  # are intentionally NOT boundaries - they belong to the current item) ----
  if [[ "$item_open" == true ]]; then
    item_lines+=("$line")
  fi
  # If item_open is false here, this is pre-first-chapter content (only
  # reachable if the file has stray text before any H1 and no syllabus
  # match triggered) - discarded, since there is no chapter to attach it to.
done

# Flush whatever item was open when the file ended.
flush_item

if [[ "$DRY_RUN" == true ]]; then
  echo
  echo "[DRY-RUN] No files written. Would create $chapter_num chapter(s) under: $BOOK_DIR"
else
  echo "Done. Chapters: $chapter_num"
  echo "Output: $BOOK_DIR"
fi
