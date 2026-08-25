## Relative References


Hierarchical URIs support relative references, which are resolved against a base URI:

**Base URI:**

```
http://example.com/dir/file.html
```

**Relative references:**

```
subdir/page.html              →  http://example.com/dir/subdir/page.html
/absolute/path.html           →  http://example.com/absolute/path.html
//other.example.com/resource  →  http://other.example.com/resource
?query=new                    →  http://example.com/dir/file.html?query=new
#fragment                     →  http://example.com/dir/file.html#fragment
```

