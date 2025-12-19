# All About Licenses (Computer Science Context)

Software licenses are legal instruments that govern how software can be used, modified, and distributed. They define the rights and responsibilities of both creators and users of software.

## What is a Software License?

A software license is a legal agreement between the software author or copyright holder and the user. It specifies what the user can and cannot do with the software, including rights to use, copy, modify, and redistribute the code.

## Major Categories of Licenses

### Proprietary Licenses
Proprietary or closed-source licenses restrict access to the source code and limit what users can do with the software. Users typically receive only the compiled binary and must agree to terms that prohibit reverse engineering, modification, or redistribution. Examples include Microsoft Windows, Adobe Photoshop, and most commercial software.

### Open Source Licenses
Open source licenses allow users to view, modify, and distribute the source code, though specific terms vary widely. The Open Source Initiative (OSI) maintains criteria for what qualifies as open source. These licenses fall into two main subcategories:

**Permissive Licenses**
Permissive licenses impose minimal restrictions on how software can be used or redistributed. They typically only require attribution to the original authors. Users can modify the code and redistribute it under different terms, including proprietary licenses. Common permissive licenses include:

- **MIT License**: One of the most permissive licenses, requiring only that the original copyright notice and license text be included with any distribution
- **BSD Licenses**: Similar to MIT but with variations (2-clause, 3-clause) that may add restrictions like prohibiting use of contributors' names for endorsement
- **Apache 2.0**: Permissive like MIT but includes explicit patent grants and protections

**Copyleft Licenses**
Copyleft licenses require that any modifications or derivative works be released under the same license terms. This ensures that the software and its derivatives remain free and open. Key copyleft licenses include:

- **GPL (GNU General Public License)**: Strong copyleft requiring that any distributed modifications or derivative works use the same GPL license. Versions include GPLv2 and GPLv3
- **LGPL (Lesser/Library GPL)**: Allows linking with proprietary software, commonly used for libraries
- **AGPL (Affero GPL)**: Extends GPL to cover software accessed over a network, closing the "SaaS loophole"
- **MPL (Mozilla Public License)**: Weak copyleft applying only to modified files, not the entire codebase

### Public Domain and Permissionless
Some software is released into the public domain or under "unlicenses" that waive all copyright claims. Examples include CC0 (Creative Commons Zero) and The Unlicense. These impose no restrictions whatsoever on use.

## Key License Characteristics

**Attribution**: Whether you must credit the original authors
**Derivative Works**: Whether and how you can create modified versions
**Patent Grants**: Whether the license includes explicit patent protections
**Trademark Rights**: Whether you can use project names and logos
**Distribution Requirements**: What you must include when distributing the software
**Compatibility**: Whether code under this license can be combined with other licenses

## Dual Licensing

Some software projects use dual licensing, offering the same software under two different licenses. This allows developers to choose which terms work best for their use case.

**Common Dual Licensing Strategies:**
- **Open Source + Commercial**: Offering GPL for open source users and a proprietary license for companies that want to use the software in closed-source products without GPL obligations. Examples include MySQL and Qt.
- **Multiple Open Source Licenses**: Providing options between different open source licenses to maximize compatibility with various projects.

This model allows projects to generate revenue while maintaining an open source option, though it requires copyright assignment or approval from all contributors.

## License Proliferation

The open source community has expressed concern about license proliferation—the creation of too many slightly different licenses. This creates confusion, legal complexity, and compatibility challenges. The OSI and Free Software Foundation recommend using established, well-understood licenses rather than creating custom ones.

## Creative Commons Licenses

While primarily used for creative works, Creative Commons licenses occasionally appear in software contexts, particularly for documentation, assets, or datasets. However, they're generally not recommended for software code itself because they weren't designed for software's unique requirements around source code, compilation, and linking.

**Common CC Licenses:**
- **CC BY**: Requires attribution only
- **CC BY-SA**: Requires attribution and share-alike (similar to copyleft)
- **CC BY-NC**: Non-commercial use only
- **CC0**: Public domain dedication

## Ethical and Restrictive Licenses

Some newer licenses attempt to impose ethical restrictions on software use:

- **Hippocratic License**: Prohibits use that violates human rights
- **Anti-996 License**: Protests overwork culture in tech companies
- **JSON License**: Famously includes "The Software shall be used for Good, not Evil"

[Unverified: Whether these licenses are legally enforceable or qualify as "open source" under OSI definitions] These licenses are controversial because they add subjective restrictions that may conflict with traditional open source principles of freedom and may not be legally enforceable.

## Software License Management in Organizations

Organizations that use open source software need processes to track and comply with licenses:

**License Compliance Tools:**
- SPDX (Software Package Data Exchange): Standardized format for communicating license information
- SBOM (Software Bill of Materials): Lists all components and their licenses in a software package
- Automated scanning tools: Identify licenses in dependencies

**Common Compliance Challenges:**
- Tracking transitive dependencies (dependencies of dependencies)
- Managing GPL contamination in proprietary products
- Ensuring proper attribution in distributed software
- Handling license changes in upstream projects

## Contributor License Agreements (CLAs)

Some open source projects require contributors to sign CLAs before accepting their code contributions. These agreements clarify copyright ownership and grant the project maintainers rights to use and relicense the contribution.

**Types:**
- **Copyright Assignment**: Contributors transfer copyright to the project
- **Copyright License**: Contributors retain copyright but grant broad usage rights

CLAs are controversial because they create friction for contributors and may enable projects to change licenses without contributor consent. Some projects use Developer Certificate of Origin (DCO) as a lighter-weight alternative.

## License Changes and Version Updates

Projects sometimes need to change licenses or update to newer versions:

- Relicensing requires permission from all copyright holders (or using a CLA that allows it)
- Some licenses include "or later version" clauses (e.g., "GPL v2 or later") that allow automatic upgrading
- Major projects like Linux use specific license versions without upgrade clauses to maintain stability

**Notable Relicensing Examples:**
- Mozilla Firefox: MPL to MPL 2.0
- React: BSD+Patents to MIT (2017)
- Various projects: Moving to more permissive licenses for wider adoption

## Free Software vs Open Source

While often used interchangeably, "free software" and "open source" represent different philosophical approaches:

**Free Software (FSF)**: Emphasizes user freedom and ethical imperatives. Focuses on four freedoms: to run, study, redistribute, and distribute modified versions. Prefers copyleft licenses.

**Open Source (OSI)**: Emphasizes practical benefits like better code quality and collaborative development. More accepting of permissive licenses and business-friendly approaches.

Most licenses approved by one organization are accepted by the other, but the philosophical difference affects how communities discuss and promote their software.

## Licenses for Specific Domains

Different software domains have developed licensing preferences:

**Web Development**: Heavily favors permissive licenses (MIT, Apache) for frameworks and libraries to encourage adoption.

**System Software**: Often uses GPL or other copyleft licenses, particularly in the Linux ecosystem.

**Academic Software**: Frequently uses BSD or MIT licenses, sometimes with academic-specific licenses.

**Embedded Systems**: Mix of proprietary and GPL, with LGPL popular for libraries that must work with proprietary code.

**Cloud Services**: Newer licenses like AGPL address SaaS deployment, while some companies create custom licenses (like MongoDB's SSPL) specifically for this use case.

## Source-Available vs Open Source

"Source-available" software makes source code visible but doesn't meet open source definitions because it restricts usage, modification, or distribution. Examples include:

- Business Source License (BSL): Restricts production use until a specific time passes
- Elastic License and MongoDB SSPL: Restrict cloud service providers from offering the software as a service
- Microsoft Reference Source License: Allows viewing but not modifying code

These licenses emerged as companies sought to prevent large cloud providers from commercializing their open source projects without contributing back.

## International Considerations

Software licenses must navigate international copyright law variations:

- Copyright term lengths vary by jurisdiction
- Moral rights (which can't be waived in some countries) may conflict with license terms
- Enforceability of specific clauses varies by legal system
- Export controls may restrict software distribution to certain countries

[Inference: Based on general copyright principles] Most major licenses are drafted to be internationally applicable, but legal interpretation can vary.

## Future Trends

The software licensing landscape continues evolving:

- Increasing tension between open source projects and cloud providers
- Growing interest in sustainability and funding models for open source maintainers
- Questions about AI training on open source code and resulting licensing implications
- Debate over ethical use restrictions and whether they belong in software licenses
- Rise of alternative models like Open Core (open source base with proprietary features)

Software licensing remains a dynamic field balancing creator rights, user freedoms, business interests, and community values.

---

# Patent Considerations in Software Licenses

## Background: Why Patents Matter in Software

Software can be protected by both **copyright** (which protects the code itself) and **patents** (which protect inventions and methods). When you write code, you automatically own the copyright. However, the code might implement patented techniques or algorithms that you or others have invented.

**The Core Problem**: Even if you release code under an open source license granting copyright permissions, users could still be sued for patent infringement if the code implements patented techniques. This creates legal uncertainty that software licenses have evolved to address.

## Patent Grants Explained

A **patent grant** is a promise from the software's contributors that they won't sue users for patent infringement based on patents they hold that are implemented in the contributed code.

**How It Works:**

When a contributor adds code to a project under a license with a patent grant (like Apache 2.0 or GPLv3), they're essentially saying: "If I hold any patents that cover what this code does, I give you permission to use those patents through this software."

**Example Scenario:**
- Alice invents and patents a novel data compression algorithm
- Alice contributes code implementing this algorithm to an Apache 2.0 licensed project
- The Apache 2.0 patent grant means Alice cannot later sue users of that project for using her patented compression algorithm (as implemented in that code)

**What Patent Grants Do NOT Cover:**
- Patents held by third parties who didn't contribute to the project
- Patents that aren't actually implemented in the contributed code
- Use of the patent outside the context of the licensed software

## Patent Retaliation Clauses Explained

**Patent retaliation** (also called **patent termination** or **defensive termination**) clauses automatically revoke someone's license rights if they sue the project or its users for patent infringement.

**The Purpose**: These clauses discourage patent litigation by making it costly for users to sue. If you sue, you lose your right to use the software.

**How It Works:**

**Apache 2.0 Example:**
The Apache License includes this mechanism: if you initiate patent litigation claiming the software infringes your patents, your patent license (and in some interpretations, your entire license) automatically terminates.

Scenario:
- Company X uses Apache-licensed software in their product
- Company X sues the software project claiming it infringes their Patent #123
- Company X's license to use the Apache software immediately terminates
- Company X must stop using the software or face copyright infringement claims

**GPLv3 Example:**
GPLv3 has broader retaliation: if you sue *anyone* alleging that *any* GPLv3-covered work infringes your patents, your patent rights under GPLv3 terminate globally for all GPLv3 software.

**Variations in Scope:**

Different licenses have different triggers:
- **Narrow**: Only terminates if you sue *this specific project*
- **Medium**: Terminates if you sue *any user* of this project  
- **Broad**: Terminates if you sue *anyone* over *any* implementation covered by the license

## Defensive Termination vs Patent Retaliation

These terms are often used interchangeably, but there's a subtle distinction:

**Defensive Termination**: Generally refers to termination provisions designed to protect the project from patent aggression

**Patent Retaliation**: Specifically emphasizes the retaliatory nature—you attacked with patents, so your license is revoked in response

Both serve the same function: making patent litigation against open source projects and their users economically unattractive.

## Real-World Impact

**Why This Matters:**

**Before explicit patent provisions**, the open source community faced uncertainty:
1. Companies could contribute code to open source projects
2. Others would adopt and build on that code
3. The contributing company could then sue adopters for patent infringement
4. This created a "submarine patent" risk in open source

**After patent grants became common**, contributors couldn't use patents as weapons against users of code they contributed.

## Historical Context: High-Profile Patent Litigation

Several incidents made patent provisions in licenses more important:

**The SCO Lawsuit (2003-2010)**: SCO claimed ownership of Unix code in Linux and sued major Linux users. While primarily a copyright case, it highlighted legal risks in open source.

**Microsoft's Patent Claims (2000s)**: Microsoft claimed Linux infringed hundreds of its patents, creating uncertainty about open source safety. This motivated GPLv3's strong patent provisions.

**The Smartphone Patent Wars (2010s)**: Apple vs Samsung, Oracle vs Google, and others demonstrated how patents could be weaponized in software. This increased awareness of patent risks in all software, including open source.

**React's BSD+Patents License Controversy (2017)**: Facebook's React library included a patent grant that terminated if anyone sued Facebook over *any* patents, not just React-related ones. The community saw this as overreaching, and Facebook eventually changed React to MIT license.

## Comparing Patent Provisions Across Licenses

**Apache 2.0:**
- Includes explicit patent grant from contributors
- Patent license terminates if you sue over the software
- [Inference: Based on the license text structure] Relatively narrow retaliation focused on the specific software

**GPLv3:**
- Explicit patent grant from contributors
- Broad retaliation: patent rights terminate if you sue over any GPLv3 software
- Additional protections against patent deals that would restrict user freedoms

**GPLv2:**
- No explicit patent grant
- [Inference: Based on when the license was written] Written before software patents were prevalent
- Patent coverage is implied but not explicit

**MIT/BSD:**
- No explicit patent provisions
- [Inference: Based on license simplicity] Users rely on implicit license or separate patent licenses
- Less protection but also less complexity

**Mozilla Public License 2.0:**
- Explicit patent grant
- Patent license terminates if you sue claiming infringement

## Practical Implications for Users

**If you're using software with patent grants:**
- You have explicit permission for patents covering the code
- You're safer from patent lawsuits from contributors
- You may lose your license if you sue (depending on retaliation clauses)

**If you're contributing to such projects:**
- You're granting patent rights for your contributions
- You cannot later monetize those patents against project users
- You should understand what patents you might be granting

**If you're choosing a license:**
- Include patent provisions for legal clarity and user protection
- Consider how broad or narrow your retaliation clause should be
- Balance protection with not being too restrictive (see React controversy)

## Limitations and Uncertainties

[Unverified: As patent law varies by jurisdiction and continues to evolve through court decisions] Several aspects remain uncertain:

- How courts will interpret these patent provisions (limited case law exists)
- Whether some patent clauses are enforceable in all jurisdictions
- What constitutes "patent litigation" that triggers termination
- How patent grants interact with patent pools and defensive patent organizations

The software patent landscape and how licenses address it continues to evolve as new legal precedents are established and the technology industry's relationship with patents changes.

---

# The SaaS Loophole Explained

## What is the SaaS Loophole?

The **SaaS loophole** (Software-as-a-Service loophole) is a gap in traditional copyleft licenses like the GPL that allows companies to use and modify open source software without sharing their modifications, as long as they only provide access to the software over a network rather than distributing it directly.

## How Traditional Copyleft Works

To understand the loophole, you need to understand what triggers copyleft obligations:

**GPL and similar licenses** require sharing source code only when you **distribute** the software. Distribution traditionally meant:
- Giving someone a copy of the compiled binary
- Selling software on physical media
- Providing downloadable software
- Bundling software with hardware

**The Key Trigger**: Physical or digital transfer of the software to another party.

## How the Loophole Works

**The Exploitation:**

1. Company takes GPL-licensed software
2. Company modifies it extensively with proprietary improvements
3. Company runs the modified software on their own servers
4. Company provides access to users over the internet (as a web service/API)
5. Users never receive a copy of the software itself
6. Since no distribution occurred, GPL obligations don't trigger
7. Company keeps all modifications proprietary

**Classic Example:**.

Imagine a company takes GPL-licensed database software, adds advanced analytics features, machine learning capabilities, and a sophisticated UI. Instead of selling this improved software, they run it on their servers and charge customers monthly fees to access it via web browser. Under GPL, they never have to share their valuable improvements because they never distributed the software—users just access it remotely.

## Why This Matters

**Before Cloud Computing**: Distribution was the primary way users received software. Copyleft licenses effectively ensured improvements were shared.

**After Cloud Computing**: Companies realized they could gain all the benefits of open source (free code, community contributions, no licensing fees) while keeping their competitive improvements secret, as long as they deployed as SaaS rather than distributing software.

**Impact on Open Source Communities:**

- Original developers see their work used commercially without getting improvements back
- Cloud providers build businesses on open source without contributing proportionally
- The reciprocal nature of copyleft (share-alike) breaks down
- Community development slows because major users don't contribute back

## The AGPL Solution

The **GNU Affero General Public License (AGPL)** was created specifically to close this loophole.

**How AGPL Differs:**

AGPL includes a crucial additional requirement: if you modify AGPL software and let users interact with it over a network, you must provide those users with the modified source code, even though you're not distributing the software.

**The Key Clause:**

From AGPLv3: "if you modify the Program, your modified version must prominently offer all users interacting with it remotely through a computer network...an opportunity to receive the Corresponding Source of your version"

**What This Means:**

- Run modified AGPL software as a web service → must share source code
- Users access your AGPL-based application remotely → must share source code  
- Provide API access to modified AGPL software → must share source code

**AGPL treats network access as equivalent to distribution for copyleft purposes.**

## Real-World Deployment Examples

**Without AGPL (GPL loophole in action):**
- Google uses and modifies vast amounts of GPL software internally
- Runs it on their servers to power services
- Never distributes modified versions to users
- Keeps all improvements proprietary
- Fully compliant with GPL

**With AGPL:**
- MongoDB was originally AGPL
- If AWS wanted to offer MongoDB as a service, they'd need to share any modifications
- This protects the original developers' interests
- [Inference: Based on business incentives] Cloud providers are less likely to offer AGPL software as managed services because of this requirement

## Industry Reactions and Controversies

**Many Companies Avoid AGPL:**

Large tech companies often have policies prohibiting or restricting AGPL software use because:
- Risk of accidentally triggering source code disclosure obligations
- Complexity in determining when network interaction counts
- Legal uncertainty about scope and enforcement
- Desire to keep competitive advantages proprietary

**The "Google Ban":**
[Unverified: While widely reported, specific internal policy details are not public] Google reportedly has internal policies restricting AGPL software, though the exact scope varies.

**MongoDB's License Change:**

In 2018, MongoDB changed from AGPL to the **Server Side Public License (SSPL)**, which they created specifically because:
- Cloud providers (particularly AWS) were offering hosted MongoDB services
- MongoDB Inc. wanted compensation or contributions from these providers
- AGPL wasn't seen as strong enough protection

[Unverified: Whether SSPL qualifies as "open source"] SSPL is controversial because it extends requirements beyond the software itself to the entire service stack, which many argue goes beyond open source principles. The OSI has not approved SSPL as an open source license.

## Other Responses to the SaaS Loophole

**Business Source License (BSL):**
- Restricts production use for a certain period
- After time passes (e.g., 3 years), converts to open source
- Used by companies like MariaDB, CockroachDB
- Prevents immediate cloud provider competition while eventually becoming truly open

**Commons Clause:**
- An addendum to existing licenses
- Prohibits selling the software as a service
- Highly controversial—[Unverified: whether it qualifies as open source] generally not considered open source by OSI

**Elastic License:**
- Created by Elastic (Elasticsearch) in response to AWS offering Elasticsearch as a service
- Prohibits offering as a managed service
- Sparked major controversy and AWS created an Elasticsearch fork

**Redis's License Changes:**
- Redis Labs changed certain modules from open source to proprietary licenses
- Response to cloud providers offering Redis without contributing back
- Community concern about sustainability of open source business models

## Legal and Philosophical Debates

**Enforcement Challenges:**

[Unverified: As there is limited case law] Questions remain about AGPL enforcement:
- What constitutes "interacting remotely through a computer network"?
- Does an internal tool used by employees count?
- What about API access with no human users?
- How is "prominent offer" of source code defined?
- Can you charge for source code access?

**Philosophical Divide:**

**Pro-AGPL view**: Closing the loophole preserves the intent of copyleft—ensuring improvements benefit everyone. The spirit of share-alike should apply regardless of delivery method.

**Anti-AGPL view**: AGPL goes too far by making internal use trigger obligations. It's overly complex, legally uncertain, and harms adoption. Traditional GPL's focus on distribution was appropriate.

**Pragmatic view**: AGPL serves important purposes but isn't right for every project. The loophole revealed that delivery methods changed but license principles didn't evolve fast enough.

## When to Use AGPL

**Good Use Cases:**
- Server-side applications likely to be deployed as services
- Projects wanting to prevent cloud provider exploitation
- Software where community improvements are crucial
- When you want strongest copyleft protection available

**Potential Drawbacks:**
- Significantly reduced adoption due to corporate policies against AGPL
- May prevent legitimate uses that would be fine under GPL
- Added complexity in compliance and legal interpretation
- Can limit commercial opportunities if companies refuse to use it

## The Broader Trend

The SaaS loophole exposed a fundamental challenge: **traditional open source licenses were designed for a world of software distribution, but the industry moved to a world of software access.**

This has led to:
1. New licenses trying to address cloud/SaaS deployment (AGPL, SSPL, BSL, Elastic License)
2. Ongoing tension between open source principles and sustainable business models
3. Debate about whether "open source" must allow any use, or can restrict commercial exploitation
4. Questions about fairness when large cloud providers profit enormously from projects they didn't create

The SaaS loophole and responses to it represent one of the most significant evolutions in software licensing since the original GPL was created, reflecting the transformation from packaged software to cloud services as the dominant software delivery model.

---

# Royalties

Royalties are payments made to the owner of a particular asset for the ongoing use of that asset. They're typically calculated as a percentage of revenue or a fixed amount per unit sold or used.

Common types of royalties include:

**Intellectual property royalties** - Authors receive royalties from book sales, musicians earn them from song plays and sales, and patent holders collect them when others use their inventions.

**Natural resource royalties** - Companies pay landowners or governments for extracting minerals, oil, gas, or timber from their property.

**Franchise royalties** - Franchisees pay ongoing fees to franchisors for using their brand name, business model, and support systems.

**Licensing royalties** - When someone licenses software, artwork, or trademarks for commercial use, they often pay the rights holder.

## What "Royalty-Free" Means

"Royalty-free" is somewhat misleading because it doesn't necessarily mean "free of charge." Instead, it means:

You pay a **one-time fee** (or sometimes nothing) to use the asset, and then you can use it without paying ongoing royalties. You're not charged based on how many times you use it, how many copies you make, or how much revenue you generate from using it.

**Common royalty-free assets:**
- Stock photos and videos
- Music for content creation
- Fonts
- Graphics and illustrations

**Important limitation:** Royalty-free licenses still have restrictions. They typically don't give you ownership of the asset or allow you to resell it as your own work. You need to read the specific license terms to understand what you can and cannot do.