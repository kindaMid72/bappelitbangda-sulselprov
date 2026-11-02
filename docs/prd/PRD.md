Status: canonical
Last reviewed: 2026-11-02
Source: Google Doc "PRD Pembangunan Ulang Situs Web Bappelitbangda Sulsel v1.1" (English: "PRD: Rebuilding the Website of Bappelitbangda of South Sulawesi, v1.1")
Source id: 1AVENcFTXL9Oq-QnqwATAegQENVnz2FqGc2EaBnfl8UU
Source URL: https://docs.google.com/document/d/1AVENcFTXL9Oq-QnqwATAegQENVnz2FqGc2EaBnfl8UU/edit
Version: 1.1
Language: English. 1:1 translation (2026-11-02) of the Indonesian text export; the body keeps the original line-for-line structure. Requirement IDs, numbers and URLs are unchanged.
Google Doc modified: 2026-11-02T03:31:42Z
Exported: 2026-11-02 (text export; tables flattened, images and Appendix A xlsx not included)
Approval: NOT SIGNED YET (Section 13 signature table is empty)
sha256 of the English body below (text after the --- line and the blank line that follows it): 2e8ba03a62efc6414852af75605dfce67acb97a94b4666421a8c8c40712c1d9a
sha256 of the original Indonesian export body: 900e70ddfe188337572bae38e3ca94e083dbaf9f983d3f17c220840deea1626e
Note: the Google Doc (Indonesian) is the master. If this copy and the Doc differ, the Doc wins; re-export, re-translate and update this header. The Indonesian export is not kept in this repo copy.

---

# **PRD: Rebuilding the Website of Bappelitbangda of South Sulawesi Province**

## **Document Control**

|  |  |
| :-: | :-: |
| Attribute | Description |
| Project | Rebuilding the website of Bappelitbangda of South Sulawesi Province |
| Version | 1.1 |
| Status | For partner review and approval |
| Date | 2 November 2026 |
| Product owner | Bappelitbangda of South Sulawesi Province |
| Infrastructure provider | Department of Communication, Informatics, Statistics and Cryptography (Dinas Komunikasi, Informatika, Statistik dan Persandian; Diskominfo SP) of South Sulawesi Province |
| Author | Kerja Praktik (internship) development team at Diskominfo SP Sulsel (Back-end and Front-end) |
| Basis of preparation | Analysis of the old site on 21 October 2026 and the Platform Requirements Document (final, 22 October 2026) |
| Companion document | Appendix A: Old Site Inventory (separate Excel file) |

### **Revision history**

|  |  |  |  |
| :-: | :-: | :-: | :-: |
| Version | Date | Changes | Author |
| 1.0 | 27 October 2026 | First release for partner review | Development team |
| 1.1 | 2 November 2026 | Senior engineer review: captcha on public forms (NFR-07); encryption of data in transit and at rest (NFR-17, new); two-factor authentication and login delay (FR-33, NFR-05); logging of personal data access (NFR-08); antivirus scanning of uploads (NFR-06); ASVS level 2 for the admin panel and PPID; Appendix D Technical Decisions; OQ-15 through OQ-17 | Development team |

## **1. Executive Summary**

Bappelitbangda of South Sulawesi Province is rebuilding its official website so that staff can manage content without a developer, public information services (PPID) are recorded and monitored, and page quality can be measured.

The old site ([bappelitbangda.sulselprov.go.id](https://bappelitbangda.sulselprov.go.id/)) still works but is hard to maintain. The analysis on 21 October 2026 found 16 problems, five of them high-impact: the main content of pages is delivered as images, the PPID forms have no registration number or tracking, applicants' personal data is collected without a visible privacy policy, the IKM poll results make no sense, and accessibility is weak.

This document sets out what will be built: 45 functional requirements and 17 non-functional requirements, each with testable acceptance criteria. The minimum launch scope (MVP) consists of 28 functional and 12 non-functional requirements with Must priority. The main technical decisions, including architecture, database, security, and encryption, are recorded in Appendix D; the detailed specification of each module is written before that module is built.

### **Project overview**

|  |  |
| :-: | :-: |
| Item | Summary |
| What is built | A public site replacing the old site; an admin panel with five administrator roles; three PPID service forms with a follow-up queue; two surveys and two satisfaction polls |
| Content to be migrated | 1,884 publications, 71 document categories with their files, about 100 static pages, 241 rows of the staff list, 16 application links |
| MVP scope | 28 functional and 12 non-functional requirements with Must priority (Section 9) |
| Technology | Svelte front-end, Go back-end |
| Infrastructure | Diskominfo SP Sulsel server; domain remains under sulselprov.go.id |
| Implementer and period | Kerja Praktik (internship) development team of 2 members (Back-end and Front-end); three months starting 19 October 2026 |

### **Decisions requested from the partners**

1.  Approve this document as the basis of the work (Section 13).
2.  Answer the open questions in Section 11. The three that most affect the early work: OQ-04 (hosting specification), OQ-01 (export of the old site's database and files), and OQ-02 (where the current PPID form data goes).
3.  Decide the scope committed for the implementation period: MVP only, or MVP and Phase 2 (OQ-14).

### **How to read this document**

  - Priorities use the MoSCoW scheme: Must (mandatory for the MVP, written "must"), Should ("should"), Could ("can"), and Won't (not done in this period).
  - Every requirement has a fixed ID that is not renumbered: FR-nn for functional and NFR-nn for non-functional; new requirements take the next number. Other IDs: T (finding), OQ (open question), A (assumption), C (constraint), PU (public user), PE (administrator role).
  - The Origin column distinguishes requirements that already exist on the old site (Existing), those presumed to exist but not yet observed because the old admin panel could not be accessed (Existing (presumed)), and those that are new or changed (Enhancement).
  - Figures marked "initial proposal" are starting values that can be adjusted together with the partners.
  - Technical terms are explained in Appendix B.

## **2. Background, Goals, and Success Indicators**

The rebuild aims to move all functions of the old site to a platform that staff can manage without a developer, with PPID services that are recorded and monitored and page quality that can be measured.

### **2.1 Background**

The old site has 108 menu entries, 1,884 publications, 71 document categories, and three PPID service forms. Only a small share of its page types are dynamic (publications, documents, staff, applications, forms, surveys, contact); the rest, about 100 static pages, are managed as manual links.

### **2.2 Problems to be solved**

1.  **Core content cannot be read by screen readers.** The organizational structure, officials' profiles, and statistics tables are presented as images (T-01, T-14).
2.  **PPID services cannot be monitored.** There is no registration number or status tracking, and the forms collect personal data (KTP, phone, address) without a visible privacy policy (T-09, T-10).
3.  **Official figures are inaccurate.** The IKM poll results make no sense and the download counter is inconsistent (T-08, T-05).
4.  **Manual and error-prone management.** Menus and pages are manual links, every structural change creates a new page (35 cloned pages), and there is no sitemap or global search (T-02, T-03, T-13, T-15).

Details of the 16 findings are in Section 5.

### **2.3 Goals**

1.  Move all observed functions of the old site to the new platform without losing content and without breaking old links.
2.  Enable Public Relations (Humas), Secretariat, and PPID staff to manage content from the admin panel without a developer.
3.  Make PPID services recorded and monitored, with response deadlines flagged automatically.
4.  Present official figures (poll results, download counts) that can be reconciled with the raw data.
5.  Meet measurable quality standards: performance, accessibility, SEO, and security.

### **2.4 Success indicators**

Each indicator has a baseline and a target; measurement follows the protocol in Section 8.1.

|  |  |  |  |
| :-: | :-: | :-: | :-: |
| Indicator | Old site condition | Target | Basis |
| Migration completeness | No measure yet | Difference of 0 for 1,884 publications, 71 document categories, 100 static pages, 241 staff, and 16 applications; missing document files 0 | NFR-12 |
| Old links keep working | Not applicable | 100% of old URLs in Appendix A return 301 to the equivalent or 200, with at most 1 hop | FR-41, NFR-13 |
| Broken menu links | 1 | 0 | FR-02 |
| PPID service tracking | No registration number or status tracking | MVP: 100% of submissions enter the officer queue. Phase 2: 100% of submissions get a ticket number and their status can be tracked publicly | FR-24, FR-23 |
| Poll result accuracy | "Dissatisfied" (Tidak Puas) 48% identical across 19 questions | Percentages equal the manual count from the raw answers (difference of 0) | FR-27 |
| Download count consistency | Difference of 10 in the RPJMD category (1,759 and 1,749) | Difference of 0 (Phase 2) | FR-18 |
| Accessibility | Zoom restricted; image content without alternative text; not yet measured | WCAG 2.1 AA: 0 serious or critical violations in automated testing | NFR-03 |
| Page speed | Not yet measured | LCP of 2.5 seconds or less; Lighthouse Performance score of 85 or more | NFR-01 |
| SEO quality | sitemap.xml and robots.txt return 404; metadata contains placeholders | Both available; 0 placeholders in metadata; Lighthouse SEO score of 95 or more | FR-42, NFR-04 |
| Management independence | Unknown (old admin panel not observed) | A new page is created, placed in the menu, and published without a developer in 10 minutes or less | FR-35 |

## **3. Stakeholders and Users**

The platform serves six groups of public users and five administrator roles; the administrator role determines access rights in the admin panel (FR-33).

### **3.1 Stakeholders**

|  |  |  |
| :-: | :-: | :-: |
| Party | Role in the project | Open questions it decides |
| Bappelitbangda (leadership and product owner) | Product owner; approves this document | OQ-05, OQ-06, OQ-07, OQ-10, OQ-13 |
| PPID Bappelitbangda | Owner of the information request, objection, and complaint services; admin panel user | OQ-02, OQ-03, OQ-08, OQ-12 |
| Humas Bappelitbangda | Manager of news, sliders, pages, and menus | OQ-09 |
| Bappelitbangda Secretariat | Document manager | OQ-08 |
| Diskominfo SP Sulsel | Provider of hosting, domain, and network; technical administrator | OQ-01, OQ-04, OQ-11, OQ-12, OQ-13 |
| Development team | Implementer: designs, builds, and tests the platform | None |

### **3.2 Public users**

|  |  |  |  |
| :-: | :-: | :-: | :-: |
| ID | Group | Main needs | Related requirements |
| PU-01 | General public | Read news and announcements; look up information about the agency | FR-04, FR-10, FR-11 |
| PU-02 | Information requesters | Submit information requests, objections, or complaints; know their status | FR-20 to FR-23 |
| PU-03 | Regional apparatus organizations (OPD) and district/city governments | Download planning and regulatory documents (RKPD, RPJMD, Renstra, and similar) | FR-15 to FR-17 |
| PU-04 | Researchers and students | Download research results (largest document category: 12,723 downloads) | FR-15, FR-16 |
| PU-05 | People with disabilities | Access all pages with a screen reader and keyboard; read special service procedures | FR-09, NFR-03 |
| PU-06 | Media and partner institutions | Find press releases, officials' profiles, and the latest organizational structure | FR-06, FR-10, FR-11 |

### **3.3 Administrator roles**

|  |  |  |  |
| :-: | :-: | :-: | :-: |
| ID | Role | Responsibilities | Related requirements |
| PE-01 | Humas Editor (Editor Humas) | Writes and publishes news; manages sliders, pages, menus, the staff list, and applications | FR-34, FR-35, FR-37 |
| PE-02 | Document Operator (Operator Dokumen; Secretariat) | Uploads and organizes documents by category | FR-17, FR-36 |
| PE-03 | PPID Officer (Petugas PPID) | Receives, processes, and answers information requests, objections, and complaints within the deadline | FR-23, FR-24 |
| PE-04 | Super Admin (Diskominfo and technical administrators) | Manages users, configuration, backups, and monitoring | FR-33, FR-39, NFR-10 |
| PE-05 | Leadership (Pimpinan; optional, read-only) | Views visit statistics and, once FR-40 is implemented, the PPID service summary and survey results | FR-32, FR-40 (deferred) |

### **3.4 Access rights matrix (initial proposal)**

M = full management, V = view only, — = no access. [Translator's note: the Indonesian original uses K (kelola penuh) for M and L (hanya lihat) for V.] This matrix is tested under FR-33 (5 roles × 9 modules = 45 cells). One user may hold more than one role; the effective access rights are the union of the permissions of all their roles, with M overriding V. The approval flow before publication has not been determined (OQ-10).

|  |  |  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| Module | Requirement | Super Admin | Humas Editor | Document Operator | PPID Officer | Leadership |
| Publications | FR-34 | M | M | — | — | — |
| Pages and menus | FR-35 | M | M | — | — | — |
| Documents and categories | FR-36 | M | — | M | V | — |
| Sliders, applications, staff, surveys, settings | FR-37 | M | M | — | — | — |
| Media library | FR-38 | M | M | M | M | — |
| PPID queue and applicant data | FR-24 | M | — | — | M | — |
| Users and roles | FR-33 | M | — | — | — | — |
| Activity log | FR-39 | V | — | — | — | — |
| Statistics and summaries | FR-32, FR-40 (deferred) | V | — | — | V | V |

## **4. Scope**

The new platform replaces all functions of the old public site and adds an admin panel; the 16 applications that are only linked from the old site are not built.

### **4.1 In scope**

1.  Public site: home page, profile and organization, PPID and public information, service standards, disability accessibility, documents, applications, publications (news, articles, announcements, and other categories), gallery, and contact.
2.  Three PPID service forms (information request, objection submission, complaint about abuse of authority) with a follow-up queue for officers.
3.  Two surveys and two satisfaction polls with results calculated from the raw answers.
4.  Admin panel for all of the content above, with five administrator roles.
5.  Migration of the old site's content: 1,884 publications, 71 document categories with their files, about 100 static pages, 241 rows of the staff list, and 16 application links.
6.  Redirection of old URLs (301) and basic SEO tooling: sitemap, robots, and metadata.
7.  Admin panel user documentation and one officer training session.

The order of work by phase is in Section 9.

### **4.2 Out of scope (Won't)**

  - Rebuilding the 16 applications and services that are only linked on the Applications page (e-Planning, SIAP Boss, SIPD, LPSE, and others); only their links are migrated.
  - The PPID Android app on the Play Store; it is only linked.
  - Integration or SSO with other Provincial Government systems.
  - Public comments on news; the old forms showed 0 comments in the sample examined.
  - Languages other than Indonesian.
  - Management of hosting, domain, and network, which are owned by the agency.
  - Rewriting content. Conversion of image-based content to text goes only as far as agreed (FR-09, OQ-06).
  - Summary for leadership (FR-40): deferred and reviewed again after release.

### **4.3 System boundary**

\[The system boundary diagram has not been carried over into this file.\] Public users and administrators interact with the platform; hosting, domain, and network are provided by the agency, while the 16 applications and the PPID Android app are only linked.

## **5. Findings from the Analysis of the Current Site**

The old site has 108 menu entries, but only a small share of its page types are dynamic (publications, documents, staff, applications, forms, surveys, contact). The biggest problems lie in the 100 static pages, which in the examples read often present the main content as images, and in the document, poll, and PPID form modules. Per-page details are in Appendix A.

### **5.1 Method and limits of observation**

  - **Source:** public pages of the old site, read without logging in on 21 October 2026.
  - **Coverage:** all 108 menu entries were inventoried; 21 of them were opened and read directly, and 87 were classified from the menu title, URL pattern, and similar page templates (the Verification column in Appendix A).
  - **Limits:** the admin panel, database, and logs were not observed. JavaScript-rendered content, form input types, captcha, and the destination of form data cannot be read from outside. The performance, accessibility, and security of the old site have not been measured.

### **5.2 Baseline data of the old site**

|  |  |  |
| :-: | :-: | :-: |
| Item | Value | Verification |
| Menu entries | 108 (10 level 1, 39 level 2, 59 level 3) | Direct |
| Static pages (/pages/...) | 100 menu entries; 13 read directly, 87 classified from URL pattern and title | Partly direct |
| Cloned pages per period | 35: organizational structure 12, PPID structure 7, officials' profiles 3, PPID officials' profiles 4, staffing statistics 5, financial statistics 4 | Direct (from menu) |
| Publications | 1,884 in 10 categories; News (Berita) 1,665 (88%), Congratulations (Ucapan Selamat) 92, Research (Penelitian) 53, Announcements (Pengumuman) 43, Articles (Artikel) 12, the remaining 19 | Direct (category sidebar) |
| Publication list | 6 items per page; News 278 pages | Direct |
| Document categories | 71 (ID 3 to 73), flat; download figures on the hub page total 146,881 | Direct |
| Top five document categories (downloads) | Research Results (Hasil Penelitian) 12,723; RKPD Regulations 9,325; RPJMD Regulations 8,546; RPD Regulations 7,782; Head of Agency Decrees (Keputusan Kepala Badan) 6,389 | Direct |
| Periodic Information page (Informasi Berkala) | 100 links in the page body: 63 to files, 31 to document categories, 4 external, 2 other | Direct |
| Staff list | 241 rows, 5 columns (name, position, rank, education, division) | Direct |
| Applications page | 16 outbound links | Direct |
| Home page slider | 10 slides | Direct |
| Interactive pages | 8: 3 PPID forms, 1 contact, 2 surveys, 2 polls | Direct |
| Visitor counter on the site | 823,806 throughout 2026 as of 21 October 2026 (not necessarily unique visitors) | Direct |

### **5.3 Findings**

Impact is the authors' assessment: High if it affects service compliance, accessibility, or the accuracy of official data; Medium if it reduces usability or maintainability; Low if cosmetic or of minor effect. Of the 16 findings, 5 have High impact, 6 Medium, and 5 Low.

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Finding | Evidence | Impact | Addressed by |
| T-01 | Core content is only images: organizational structure, officials' profiles, service schedules and channels, procedure flows, statistics tables and charts | The 2026 organizational structure page and the 2026 officials' profile page contain only a single image; the 2024 staffing statistics use an image of a table | High | FR-06, FR-09 |
| T-02 | Every change of structure or official creates a new page instead of a new version | 35 cloned pages in the menu | Medium | FR-06 |
| T-03 | Menus and pages are managed as manual links; one link is broken | "Procedure for Complaints about Abuse of Authority by Officials" (Prosedur Pengaduan Penyalahgunaan Wewenang Pejabat) contains a tab character in its URL | Low | FR-02, FR-05 |
| T-04 | Periodic Information is a single long static page with 63 file links and 31 document category links, separate from the Documents module | Periodic information page (informasi-berkala): 100 links in the page body | Medium | FR-19 |
| T-05 | Flat document taxonomy with no year or search; inconsistent download counter | 71 categories side by side; the RPJMD hub states 1,759 downloads, but the per-file total is only 1,749 (difference of 10) | Medium | FR-15 to FR-18 |
| T-06 | Stale "Popular" sidebar without images; the Articles category is nearly dead; congratulatory categories fragment the news | "Popular" contains posts from 2022 to 2024; Articles has 12 posts, latest April 2023; Congratulations (Ucapan Selamat), Condolences (Belasungkawa), and Thank-yous (Ucapan Terima Kasih) = 105 posts | Low | FR-10, FR-13 |
| T-07 | The Photo and Video menus are empty | The pages contain only a placeholder image or a title | Low | FR-14 |
| T-08 | The IKM poll results make no sense and carry a wrong title | "Dissatisfied" (Tidak Puas) 48% identical across 19 questions, "Less Satisfied" (Kurang Puas) 0%; page title "Polling Survey Layanan Informasi Publik" (Public Information Service Survey Poll); the IKM form has 24 items, the poll only 19 | High | FR-27 |
| T-09 | The PPID forms show no registration number or status tracking | No tracking menu among the 108 entries; the destination of data after the "Proses" (Process) button is not visible from outside | High | FR-20 to FR-24 |
| T-10 | The information request form collects personal data (KTP, phone, address) without a visible privacy policy | The "KTP" field is mandatory for applicants and information users | High | FR-20, NFR-08 |
| T-11 | The staff list displays all 241 rows at once; inconsistent writing | The Education column contains "S2", "S-1 Manajemen", "SLTA", "SLTA Sederajat"; 82 rows have rank "-" | Low | FR-07, FR-08 |
| T-12 | Social media links in the topbar differ from the footer; metadata contains placeholders | Facebook and Instagram point to different accounts; meta contains POSTAL\\\_CODE and FACEBOOK\\\_FIRST\\\_NAME | Low | FR-03, FR-42 |
| T-13 | No sitemap.xml or robots.txt; the 404 page is plain text | Both addresses return 404 | Medium | FR-42, FR-43 |
| T-14 | Weak accessibility at the basic level | The meta viewport contains maximum-scale=1 (zoom restricted); the third-party accessibility widget depends on JavaScript; image content without text | High | NFR-03, FR-09 |
| T-15 | No global search; only a "Search Articles" (Cari Artikel) box on the news and articles pages | Menu and header | Medium | FR-04 |
| T-16 | The Applications page is 16 logo images without descriptions; file links are absolute to the old domain | /content/uploads/ and /content/new\\\_directory/2024/ | Medium | FR-28, FR-41 |

### **5.4 Items that could not yet be verified**

The contents of the Activity Calendar (Kalender Kegiatan; rendered by JavaScript), the input type of the KTP field, whether the old site has a captcha (this does not affect NFR-07, which requires a captcha on the new site), the purpose of storing form data, and the entire old admin panel. Except for the captcha, all of these are in the list of open questions (Section 11).

### **5.5 Enhancements without a finding**

FR-32, FR-33, FR-38, FR-39, and FR-40 come from management needs (statistics, roles, media library, log, summary), not from defects visible on the public site, because the old admin panel was not observed. FR-40 is deferred (Section 4.2). FR-44 comes from the visitor counter observed in the footer of the old site, and FR-45 from an additional proposal.

## **6. Functional Requirements**

The platform must meet 45 functional requirements in nine modules: 28 Must, 12 Should, 4 Could, and 1 Won't (deferred). Must goes into the MVP; Should and Could go into later phases (Section 9); Won't is not done in this release (Section 4.2). By the Origin column, 19 requirements come from the old site (Existing), 4 are presumed to exist in the old admin panel (Existing (presumed)), and 22 are Enhancements.

|  |  |  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| Module | Section | Must | Should | Could | Won't | Total |
| Home page, navigation, and search | 6.1 | 4 | 2 | 0 | 0 | 6 |
| Static pages and organization | 6.2 | 2 | 3 | 0 | 0 | 5 |
| Publications | 6.3 | 3 | 1 | 1 | 0 | 5 |
| Documents | 6.4 | 1 | 3 | 0 | 0 | 4 |
| PPID and public information | 6.5 | 5 | 1 | 0 | 0 | 6 |
| Surveys and polls | 6.6 | 3 | 0 | 0 | 0 | 3 |
| Applications, contact, and other services | 6.7 | 2 | 0 | 3 | 0 | 5 |
| Admin panel | 6.8 | 6 | 1 | 0 | 1 | 8 |
| SEO and URL compatibility | 6.9 | 2 | 1 | 0 | 0 | 3 |
| \*\*Total\*\* |   | \*\*28\*\* | \*\*12\*\* | \*\*4\*\* | \*\*1\*\* | \*\*45\*\* |

### **6.1 Home page, navigation, and search**

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Requirement | Priority | Origin | Acceptance criteria |
| FR-01 | The system must display a home page containing a banner slider, three PPID form shortcuts, a message from the head of the agency, the seven latest news items, a survey block, and the address and contact details. | Must | Existing | (1) The Humas Editor can change the slider, message, and shortcuts without redeploying; (2) the seven latest news items fill automatically from published publications; (3) all blocks are readable without truncation and without horizontal scrolling at a width of 360 px |
| FR-02 | The system must provide navigation up to three levels deep, including the mobile menu, managed from a single data source. | Must | Existing | (1) Adding or moving a menu item in the admin panel appears on the public site within 1 minute; (2) an automated link test across all menu items finds 0 broken links (old site baseline: 1) |
| FR-03 | The system must take the address, phone, email, and social media links from a single site setting for the topbar, footer, and contact page. | Must | Enhancement | Changing one value in the settings updates all three locations (3 of 3); searching the templates for that value finds 0 hard-coded copies |
| FR-44 | The system must display public visitor statistics (today, this month, this year) in the footer of every public page. | Must | Existing | The three figures appear in the footer on 100% of public page template types (tested on 5 template types); the today figure resets to 0 at 00:00 WITA; the this-month figure equals the sum of the daily figures for the current month (difference of 0); the count is of visits, not unique visitors, as on the old site |
| FR-04 | The system should provide global search across publications, pages, and documents with results grouped by type. | Should | Enhancement | The query "RKPD 2025" on the migrated data returns results in 1 second or less (p95 over 20 repetitions), containing related documents and publications in separate groups; a query with no results shows a message and a link to the home page |
| FR-45 | The system should allow the Humas Editor to designate one static page (FR-05) as the main hero of the home page, showing the title, summary, main image, and a link to that page at the top of the home page. | Should | Enhancement | The Humas Editor changes the hero page from the admin panel without redeploying; the change appears on the home page within 1 minute; the hero is readable without horizontal scrolling at a width of 360 px; the home page Performance score still meets NFR-01 |

### **6.2 Static pages and organization**

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Requirement | Priority | Origin | Acceptance criteria |
| FR-05 | The system must provide static pages with a rich text editor (title, lists, tables, images, attachments), slug, draft or published status, and position in the menu. | Must | Existing | 100% of the 100 old static pages migrated with identical slugs; in a 10% sample (10 pages) no image, link, or table is broken |
| FR-07 | The system must display the staff list (name, position, rank, education, division) with search, division filter, sorting, and pagination. | Must | Existing | 241 rows migrated (difference of 0); name search shows results in 1 second or less (p95); one page holds at most 25 rows |
| FR-06 | The system should manage periodic content (organizational structure, officials' profiles, staffing and financial statistics) as a series with effective dates, with a page showing the current version and a list of archives. | Should | Enhancement | Adding a new version adds no menu entry (0 entries); the current version switches automatically on the effective date; the 35 old pages are mapped to 6 series according to the decision on OQ-07; old versions can still be opened from the archive |
| FR-08 | The system should import and update the staff list from CSV files and normalize education and rank values to a pick list. | Should | Enhancement | Import of 241 rows completes in 30 seconds or less without errors; 100% of education column values come from the pick list (baseline: 4 inconsistent spellings in the sample read); invalid rows are reported per row and do not fail the whole import |
| FR-09 | The system should supplement image-based content with alternative text and present statistics tables as structured data displayed as HTML tables. | Should | Enhancement | 100% of meaningful images have alternative text; the 2024 staffing statistics are read by a screen reader as a table with column headers (scope of content conversion depends on OQ-06) |

### **6.3 Publications**

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Requirement | Priority | Origin | Acceptance criteria |
| FR-10 | The system must display the publication list per category (10 categories) as cards containing image, title, category, date, and excerpt, with pagination. | Must | Existing | Newest first; the number of items per page is configurable (initial value 6, same as the old site); the News category contains all 1,665 posts (difference of 0) |
| FR-11 | The system must display publication detail: title, category, date, view count, rich text content with images, tags, and related publications. | Must | Existing | 1,884 publications migrated with identical slugs (difference of 0); publication date equals the old site if the database source is available (OQ-01); the view count increases by 1 per visit; 4 related publications are shown, same as the old site |
| FR-13 | The system must display a sidebar containing categories with post counts, a search box, and "Popular" calculated from views in the last 30 days. | Must | Enhancement | "Popular" contains at most 5 posts viewed in the last 30 days, sorted by view count (baseline: posts from 2022 to 2024); the post count per category equals the database count (difference of 0) |
| FR-12 | The system should provide a tag page showing the list of publications per tag. | Should | Existing | 100% of tags on detail pages lead to a list containing the publications with that tag; tags without publications are not displayed |
| FR-14 | The system can provide a photo gallery (albums) and videos (YouTube links). | Could | Existing | The Photo and Video menus appear only if they contain at least 1 item; albums and videos can be managed from the admin panel (content decision: OQ-09) |

### **6.4 Documents**

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Requirement | Priority | Origin | Acceptance criteria |
| FR-15 | The system must display the document catalog: each category shows its download count, and the list per category contains title, update date, download count, View and Download buttons, and pagination. | Must | Existing | 71 categories and all files migrated (missing files 0); 100% of download links return status 200 in the link test |
| FR-16 | The system should provide document search and filters across categories by keyword, category, and year. | Should | Enhancement | On 5 test queries (for example "Renstra" with the year 2024 filter) only matching documents appear (100% precision); response time 1 second or less (p95) |
| FR-17 | The system should build a hierarchical document taxonomy (group, then category) agreed with the content owner, with old category IDs mapped to new categories. | Should | Enhancement | The mapping table of the 71 old categories to new ones is approved by Bappelitbangda (OQ-08); 100% of old IDs are mapped; 0 documents without a category |
| FR-18 | The system should record the download counter on the server when a file is downloaded (one count per visitor per file per day) and migrate the old values as the starting value. | Should | Enhancement | The figure on the category page equals the per-file total (difference of 0; baseline: difference of 10 in the RPJMD category); repeated downloads by the same visitor on the same day count as 1 |

### **6.5 PPID and public information**

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Requirement | Priority | Origin | Acceptance criteria |
| FR-19 | The system must display the pages Public Information List, Periodic Information, Information Available at Any Time, Immediately Available Information, and Excluded Information from the Documents module according to the information-type marker, not manual tables and links. | Must | Enhancement | The 63 file links and 31 category links on the old Periodic Information page are mapped to the Documents module (100% coverage); a new document marked "periodic" appears on that page within 1 minute without editing the page |
| FR-20 | The system must provide an information request form with the applicant's identity (name, KTP, email, phone, address, occupation), the information user's identity (name, KTP, email, phone), details of the information, and purpose of use. | Must | Existing | The 12 old fields are available, mandatory, and validated on the server; successful submission saves the data and shows a confirmation in 5 seconds or less; the data appears in the FR-24 queue; captcha and submission limit follow NFR-07; the KTP number is encrypted per NFR-17 (KTP field type: OQ-03) |
| FR-21 | The system must provide an objection submission form with the reason for the information request, the applicant's identity, an option of not represented or represented (representative's identity and a power-of-attorney letter as PDF or image), seven grounds for objection, and a short chronology. | Must | Existing | The seven old grounds for objection are available as options; the power-of-attorney letter is mandatory if represented; data appears in the FR-24 queue in 5 seconds or less; captcha and submission limit follow NFR-07; the power-of-attorney letter is encrypted per NFR-17 |
| FR-22 | The system must provide a complaint form about abuse of authority with the complainant's identity, the official's name and position, an explanation, and evidence uploads (.pdf, .jpg, .zip, .rar). | Must | Existing | The 8 old fields are available; 100% of files outside the type and size rules of NFR-06 are rejected; data appears in the FR-24 queue in 5 seconds or less; captcha and submission limit follow NFR-07; evidence attachments are encrypted per NFR-17 (.zip and .rar types: OQ-12) |
| FR-24 | The system must provide a PPID officer queue containing submissions by type and status, with functions to change status, record answers and attachments, and a flag for the 10-working-day deadline and the 7-working-day extension for information requests. | Must | Enhancement | 100% of submissions appear in the queue; requests that pass 10 working days without an answer or extension are flagged automatically; an extension adds 7 working days; working days are counted excluding Saturdays, Sundays, and holidays entered by the Super Admin; only PPID Officers and Super Admins can open personal data (0 violations in the access rights test); the deadlines for objections and complaints are configurable (OQ-02) |
| FR-23 | The system should give a ticket number to every submission of FR-20 to FR-22 and allow status tracking (received, verified, processed, extended, answered, rejected) through a public page, with a notification email if the address is valid. | Should | Enhancement | A unique ticket number is issued for 100% of submissions; entering a ticket number shows the current status without personal data; email is sent within 5 minutes of a status change (SMTP: OQ-11) |

### **6.6 Surveys and polls**

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Requirement | Priority | Origin | Acceptance criteria |
| FR-25 | The system must provide a public information service survey with respondent identity (name, institution, email, age, phone, date, type of service) and 17 questions on a scale from Very Good to Not Good. | Must | Existing | The 17 questions and 4 answer options are identical to the old site (difference of 0); answers are saved with the date; submissions are protected by captcha and limited per NFR-07 |
| FR-26 | The system must provide an IKM survey with respondent identity (OPD, name, age, gender, education, phone, date, position, type of service), 24 items on a scale of 1 to 4 with a reason column, a conditional cost question, and an input for service innovation. | Must | Existing | The 24 items are identical to the old site (difference of 0); the cost reasonableness question appears only if there is a service fee; answers are saved; submissions are protected by captcha and limited per NFR-07 |
| FR-27 | The system must display poll results as a percentage per option calculated from the actual number of respondents per period, with the correct page title, and allow the admin to download responses as CSV. | Must | Enhancement | On 20 test responses, the percentages for each question total 100% (rounding tolerance of 1 point) and equal the manual count (difference of 0); the CSV contains 20 response rows and 1 column header row |

### **6.7 Applications, contact, and other services**

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Requirement | Priority | Origin | Acceptance criteria |
| FR-28 | The system must display the Applications page containing cards for applications and related services (logo, name, short description, destination URL) in an order set by the admin. | Must | Existing | 16 old links migrated (difference of 0); 100% of cards have a text name and URL; the link test reports the status of each URL (third-party failures are recorded, not counted as defects) |
| FR-29 | The system must provide a contact page containing address, phone, email, location map, and a response form that goes to the admin's message inbox. | Must | Existing | A submitted message appears in the admin panel in 5 seconds or less; submissions are protected by captcha and limited per NFR-07 (the old form's fields could not be read; determined during design) |
| FR-30 | The system can display an activity calendar on the home page from agenda entries input by the admin. | Could | Existing | Entered agenda items appear on their dates (old data source: OQ-05) |
| FR-31 | The system can display a prayer times (sholat) widget on the home page. | Could | Existing | The widget is loaded deferred so that the home page Performance score still meets NFR-01 (decision whether to keep it or not: OQ-05) |
| FR-32 | The system can provide internal visit statistics (daily, monthly, most popular pages) on the admin dashboard. | Could | Enhancement | The dashboard shows daily visits for the last 30 days and the 10 most popular pages |

### **6.8 Admin panel**

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Requirement | Priority | Origin | Acceptance criteria |
| FR-33 | The system must provide admin login with roles and per-module permissions for five roles: Super Admin, Humas Editor, Document Operator, PPID Officer, and Leadership (read-only); one user can hold more than one role, and the effective permissions are the union of the permissions of all their roles. | Must | Enhancement | An access rights test of 5 roles × 9 modules (45 cells in Section 3.4) finds 0 accesses outside permissions; a user with two roles (3 test combinations) gets exactly the union of the permissions of both roles; repeated failed logins are throttled with a progressively longer delay per account and IP address (5 consecutive failures: 15-minute delay, initial value, configurable), without locking the account permanently; two-factor authentication is mandatory for Super Admin and PPID Officer with recovery codes; the approval flow before publication follows OQ-10 |
| FR-34 | The system must allow the Humas Editor to manage publications: write, edit, save as draft, schedule, publish, and set category, tags, and main image. | Must | Existing (presumed) | A published publication appears on the home page, category list, tag page, and sitemap within 1 minute; a scheduled publication is published within a 1-minute tolerance of the set time |
| FR-35 | The system must allow the Humas Editor to manage static pages and the navigation menu. | Must | Existing (presumed) | A new page is created, placed in the menu, and published without developer assistance in 10 minutes or less |
| FR-36 | The system must allow the Document Operator to manage documents and categories: upload files, fill in title and date, choose category and information-type marker, and bulk upload. | Must | Existing (presumed) | An uploaded document appears in the catalog within 1 minute; a bulk upload of 20 files completes without errors; the information-type marker is saved and read by FR-19 |
| FR-37 | The system must allow the Humas Editor and Super Admin to manage sliders, applications, staff, surveys (questions and periods), holidays for working-day calculation, and site settings. | Must | Existing (presumed) | Changes to each object appear on the public site within 1 minute without redeploying |
| FR-38 | The system must provide a media library for authorized administrators: upload images and files, type and size validation, automatic derived sizes (thumbnails), and alternative text for images. | Must | Enhancement | 100% of files of a disallowed type or size are rejected (NFR-06); a thumbnail is generated within 5 seconds per image; an image without alternative text cannot be published unless marked decorative |
| FR-39 | The system should record an activity log: who changed what and when on content and settings. | Should | Enhancement | 100% of add, edit, and delete actions are recorded with user, object, and time; the panel interface provides no function to edit or delete the log |
| FR-40 | The system can provide a summary for leadership: number and status of PPID requests, average response time, and survey results per period. | Won't | Enhancement | Deferred; if taken up again, a monthly summary can be viewed and exported as CSV; average response time is calculated in working days |

### **6.9 SEO and URL compatibility**

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| ID | Requirement | Priority | Origin | Acceptance criteria |
| FR-41 | The system must redirect (301) all old URL patterns (/pages/{slug}, /detailpost/{slug}, /category/{slug}/{page}, /all-dokumen/{id}, /tag/{slug}, /content/uploads/, /content/new\\\_directory/2024/) to their new equivalents. | Must | Enhancement | 100% of URLs in Appendix A and 100% of migrated files return 301 to the equivalent or 200, verified by a crawl script; redirect chains are no longer than 1 hop (NFR-13) |
| FR-42 | The system must generate sitemap.xml and robots.txt automatically and fill in the title, description, canonical, and Open Graph on every page. | Must | Enhancement | A crawl of all public pages finds 0 placeholders in metadata; the sitemap contains 100% of published public pages and is updated within 1 minute of publication; robots.txt returns 200 |
| FR-43 | The system should display 404 and 500 pages containing a search box and a link to the home page. | Should | Enhancement | An unknown address returns status 404 with a friendly page; a server error returns status 500 with a friendly page; responses contain 0 stack traces |

## **7. Main Process Flows**

Four flows contain the most process rules: PPID submission, documents, news publication, and surveys. Each flow points to the requirements that support it; the time parameters of all processes are summarized in Section 7.5.

### **7.1 Public information submission flow**

1.  The applicant fills in the PPID form.
2.  The system saves it and assigns a ticket number (FR-23).
3.  The PPID Officer processes it in the queue (FR-24).
4.  Written answer: 10 working days, plus 7 if extended.
5.  Decision "Answer accepted?": yes, finished with status Answered; no, the applicant files an objection (FR-21), which returns to the officer queue (step 3).

Every submission enters the officer queue (FR-24) and receives a ticket number once FR-23 is available. A written answer to an information request must be given within 10 working days and can be extended by 7 working days. An applicant who is dissatisfied or receives no answer files an objection, which returns to the same queue. Statuses on the tracking page (FR-23): received, verified, processed, extended, answered, rejected.

### **7.2 Document search and download flow**

Two entry points lead into the same catalog: visitors search or filter (FR-16), and old /all-dokumen/\[id\] links are redirected (FR-41). Then: the document list per category (FR-15), the visitor clicks View or Download, and the server records the download and sends the file (FR-18). Search (FR-16) and old links (FR-41) both end at the document list per category (FR-15); the server records each download once per visitor per file per day (FR-18).

### **7.3 News publication flow**

1.  The Humas Editor logs into the admin panel (FR-33).
2.  Writes the content and uploads images with alternative text (FR-34, FR-38).
3.  Saves as draft or schedules (FR-34).
4.  Presses Publish (FR-34).
5.  Within 1 minute the publication appears on the home page (7 latest news items, FR-01), the category list and tag page (FR-10, FR-12), and sitemap.xml (FR-42).

The Publish button updates all of those places with no extra steps.

### **7.4 Survey completion and poll result reading flow**

1.  Respondents fill in the public information service survey (17 questions, FR-25) or the IKM survey (24 items, FR-26).
2.  The system saves the answers and limits repeated submissions (NFR-07).
3.  Results are calculated from the raw answers per period (FR-27).
4.  The poll page shows the percentage per option (FR-27).
5.  The admin can download the raw responses as CSV (FR-27).

Percentages are calculated from the raw answers so that they can be reconciled with a manual count.

### **7.5 Process time parameters**

|  |  |  |  |
| :-: | :-: | :-: | :-: |
| Process | Trigger | Time limit | Source |
| Confirmation of PPID form submission | Form submission | 5 seconds or less | FR-20 to FR-22 |
| Notification email on status change | Change of submission status | 5 minutes or less | FR-23 |
| Written answer to an information request | Receipt of the request | 10 working days | UU KIP Article 22; FR-24 |
| Extension of the answer | Officer sets an extension | 7 additional working days | UU KIP Article 22; FR-24 |
| Response to objections and complaints | Receipt of the submission | Determined together with PPID | OQ-02 |
| Publication appears on the home page, category list, tag page, and sitemap | Publish button | 1 minute or less | FR-34 |
| Document appears in the catalog | Upload completes | 1 minute or less | FR-36 |
| Menu, slider, and settings changes appear on the public site | Save | 1 minute or less | FR-02, FR-37 |
| Global search and document search results | Visitor query | 1 second or less (p95) | FR-04, FR-16 |

## **8. Non-Functional Requirements**

The seventeen non-functional requirements are the platform's quality measures: 12 have Must priority and are conditions for the MVP release, and 5 have Should priority. All figures are initial proposals; availability and backup targets depend on the hosting provided (OQ-04). The classification of characteristics follows ISO/IEC 25010.

### **8.1 Measurement protocol**

  - **Test environment:** staging with fully migrated data (1,884 publications and 71 document categories), configured identically to production.
  - **Page performance:** Lighthouse with the default mobile profile, 5 measurements per page, median value, on the home page, news list, news detail, document catalog, and document list per category. After release, Chrome UX Report field data (28-day window) is compared with the targets if traffic is sufficient.
  - **Load test:** k6 for 10 minutes with 50 concurrent virtual users, with a scenario of reading the home page, lists, detail pages, search, and downloads.
  - **Accessibility:** automated axe-core on all template types, plus manual testing with a screen reader and keyboard on five key pages.
  - **Security:** OWASP ZAP scans (baseline and active scan) on staging, plus a review with the ASVS checklist (level 2 for the admin panel, authentication, and the PPID module; level 1 for other modules).
  - **Defect severity:** defined in Section 12.2.

### **8.2 List of non-functional requirements**

|  |  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: | :-: |
| ID | Characteristic | Requirement | Metric and target | Conditions and measurement tool | Priority |
| NFR-01 | Performance efficiency | Public page loading speed | Lab: LCP 2.5 seconds or less, CLS 0.1 or less, Total Blocking Time 200 ms or less, Lighthouse Performance score 85 or more. Field after release (p75): LCP 2.5 seconds or less, CLS 0.1 or less, INP 200 ms or less | Protocol in Section 8.1; Lighthouse CI or PageSpeed Insights. Lighthouse's "good" threshold is 90; 85 was chosen as the initial target | Must |
| NFR-02 | Performance efficiency | API capacity and response time | Read response p95 300 ms or less and search p95 1,000 ms or less at 50 concurrent users; 5xx errors 0% | k6 load test for 10 minutes on staging | Should |
| NFR-03 | Usability (accessibility) | WCAG 2.1 AA compliance on all public pages | 0 serious or critical violations (axe-core) across all template types; text contrast of 4.5:1 or more; 200% magnification without loss of function; zoom not restricted; all functions operable by keyboard | Automated axe-core; manual screen reader and keyboard testing on five key pages (home page, news detail, document catalog, request form, organizational structure) | Must |
| NFR-04 | Discoverability (SEO) | Rendering and metadata | Main content is in the initial HTML without JavaScript; unique title and description on 100% of pages; Lighthouse SEO score 95 or more | Lighthouse; page source check with JavaScript turned off on five key pages; metadata crawl | Must |
| NFR-05 | Security | Application security | HTTPS mandatory (TLS 1.2 or higher); CSP, HSTS, and X-Content-Type-Options headers on 100% of page responses; passwords stored with a password hash function (NFR-17); two-factor authentication (TOTP) mandatory for Super Admin and PPID Officer; admin sessions expire after 30 minutes of inactivity (initial value); 0 High or Critical findings in the pre-release scan; 100% of relevant ASVS items met or recorded as approved exceptions (level 2 for the admin panel, authentication, and the PPID module; level 1 for other modules) | OWASP ZAP on staging; review of ASVS level 1 and 2 checklists according to scope | Must |
| NFR-06 | Security | File uploads | List of allowed types per feature; maximum size per feature set according to OQ-12; type checked from file content, not extension; file names replaced; files stored outside executable directories; files from public forms are scanned by antivirus before officers can open them (scanner availability: OQ-04); 10 of 10 malicious file test cases rejected | Test cases: fake type, double extension, excessive size, malicious name, nested archive, and EICAR test file | Must |
| NFR-07 | Security | Public form protection | Captcha on the 3 PPID forms, 2 surveys, and the contact form, verified on the server with a single-use token that expires; the challenge can be solved with a keyboard and screen reader (NFR-03), does not depend on third-party services, and does not send visitor data outside the server; if verification fails technically, the PPID form shows an alternative submission path. Additional layer: submission limit per IP address per form (initial value 5 per hour, configurable). Of 100 automated submissions without a valid token, 100 are rejected; of 100 submissions reusing one token, 99 are rejected; of 100 consecutive submissions by one IP with a valid token, 95 are rejected with HTTP 429 | Automated tests on staging; manual testing with a screen reader and keyboard on the three form types; network traffic check of form pages: 0 requests to external domains | Must |
| NFR-08 | Security (privacy) | Personal data protection under Law Number 27 of 2022 | Applicant data can be read only by PPID Officers and Super Admins (0 violations in the access rights test); 0 matches of KTP, phone, and email patterns in the test application logs; forms contain a data use notice; every opening of an applicant's personal data, including the KTP number, is recorded with user, object, and time in a log that cannot be changed from the panel interface (0 openings without a record); requests from data subjects for access, correction, or deletion can be fulfilled by the Super Admin at the PPID's request; the data breach handling procedure, including the notification deadline under Law Number 27 of 2022, is written in the handover document; the data retention period is determined together with PPID (OQ-15) | Access rights test per role; pattern search on test logs; review of the notice text by PPID; access logging test on 10 openings of test data | Must |
| NFR-09 | Reliability | Availability | 99.5% per month excluding scheduled maintenance (equivalent to at most 3 hours 36 minutes of downtime in a 30-day month) | Uptime monitoring every 5 minutes; monthly report | Should |
| NFR-10 | Reliability | Backup and recovery | Daily backup of the database and files; RPO 24 hours or less; RTO 4 hours or less; backup retention 30 days (initial value); backups are encrypted (NFR-17); one restore test, including recovery of the encryption key, succeeds before the MVP release | Restore test report on staging with times recorded | Must |
| NFR-11 | Compatibility | Responsiveness and browsers | Works at screen widths of 360 to 1920 px and the last two versions of Chrome, Edge, Firefox, Safari, and Chrome Android; 0 severity 1 or 2 defects on Must requirement test scenarios across all combinations | Manual test matrix | Must |
| NFR-12 | Project requirement (migration) | Migration integrity | Content counts match the source: 1,884 publications, 71 document categories, 100 static pages, 241 staff, 16 applications (difference of 0); missing document files 0; content match on a 5% random sample of 98% or more and all mismatches fixed before release | Reconciliation script and sample check report | Must |
| NFR-13 | Project requirement (URL) | URL compatibility | 100% of old URLs in Appendix A return 301 to the equivalent or 200; redirect chains of at most 1 hop; redirect response time 100 ms or less (p95) | Crawl script on staging and 30 days after release | Must |
| NFR-14 | Maintainability | Code quality and documentation | API contract documented (100% of endpoints); versioned database schema; CI build and tests green on the main branch; automated test coverage of 60% or more on business logic; a new developer runs the system locally from the README in 30 minutes or less | CI and coverage reports; a test following the README by one person who has never run the project | Should |
| NFR-15 | Maintainability | Observability | Structured logs; health check endpoint responds in 1 second or less; 100% of 5xx errors are logged with a correlation ID | Demonstration and log review during the load test | Should |
| NFR-16 | Project requirement (localization) | Language and format | Public and admin interfaces in Indonesian (0 English interface text on inspection); dates formatted as "Kamis, 15 Oktober 2026" (Thursday, 15 October 2026) in the WITA time zone | Manual inspection of all templates | Should |
| NFR-17 | Security (cryptography) | Encryption of data in transit and at rest | In transit: TLS 1.2 or higher with TLS 1.3 enabled and no weak suites. At rest: KTP numbers, TOTP secrets, and identity or evidence attachments are encrypted with authenticated encryption AES-256-GCM or equivalent; passwords are stored with argon2id; data markers and signatures (HMAC) use SHA-256 or stronger; only standard, proven cryptographic libraries are used and no home-grown algorithms. Encryption keys are stored separately from the database, repository, and backups, can be rotated without stopping the service, and are held by two named people (one of them a Diskominfo official). Backups are encrypted. | TLS scan (testssl.sh or SSL Labs): 0 weak suites; test database dumps and backups contain 0 KTP numbers in plain text (16-digit pattern search); restore test succeeds with the key and fails without it; code review finds 0 home-grown algorithm implementations. Mandatory agency standard: OQ-16; key holders: OQ-17 | Must |

## **9. Priorities and Release Phases**

The MVP contains 28 Must functional requirements and 12 Must non-functional requirements; 12 Should requirements go into Phase 2, 4 Could requirements into Phase 3, and 1 requirement is deferred (Won't). The launch can proceed without Phase 2 and Phase 3; the scope committed for the implementation period is determined through OQ-14.

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| Phase | Contents | Requirements | Count | Reason |
| 1\\. MVP | Home page, navigation, and visitor statistics; static pages and staff list; news, detail, and sidebar; document catalog; public information and three PPID forms with the officer queue; surveys, polls, and their results; applications and contact pages; core admin panel and media library; URL redirects, sitemap, metadata | FR-01, 02, 03, 05, 07, 10, 11, 13, 15, 19, 20, 21, 22, 24, 25, 26, 27, 28, 29, 33, 34, 35, 36, 37, 38, 41, 42, 44 | 28 | Observed features of the old site, PPID service obligations, and the condition that migration must not break old links |
| 2\\. Strengthening | Global search; home page hero; versioned content series; staff import; alternative text and statistics tables; tag page; document filters and taxonomy; download counter; ticket tracking; activity log; 404 page | FR-04, 06, 08, 09, 12, 16, 17, 18, 23, 39, 43, 45 | 12 | Improves quality and compliance, but the launch can still proceed without it |
| 3\\. Additions | Photo and video gallery; activity calendar; prayer times widget; internal visit statistics | FR-14, 30, 31, 32 | 4 | Small value or awaiting a decision by the content owner (OQ-05, OQ-09) |
| Deferred (Won't) | Summary for leadership | FR-40 | 1 | Deferred; reviewed again after release |

The non-functional requirements that are conditions for the MVP release: NFR-01, 03, 04, 05, 06, 07, 08, 10, 11, 12, 13, and 17. NFR-02, 09, 14, 15, and 16 have Should priority and are not release conditions.

## **10. Assumptions, Constraints, and Dependencies**

The work is bounded by five constraints, rests on five assumptions, and requires access and decisions from Diskominfo SP Sulsel and Bappelitbangda.

### **10.1 Constraints**

|  |  |  |  |
| :-: | :-: | :-: | :-: |
| ID | Constraint | Terms | Reference |
| C-1 | Hosting | Agency infrastructure (Diskominfo SP Sulsel); specifications not yet known; deployment is done directly on the Diskominfo server | OQ-04, NFR-09, NFR-10 |
| C-2 | Domain | Remains under sulselprov.go.id | FR-41 |
| C-3 | Content source | The old site; access to the old database is not yet confirmed | OQ-01, NFR-12 |
| C-4 | Technology | Svelte front-end and Go back-end; other technical decisions are recorded in Appendix D | Appendix D |
| C-5 | Time and resources | A development team of 2 members (Back-end and Front-end) working within the Kerja Praktik (internship) framework for three months starting 19 October 2026; the detailed schedule is not included in this document | OQ-14, Section 9 |

### **10.2 Assumptions**

|  |  |  |
| :-: | :-: | :-: |
| ID | Assumption | Consequence if untrue |
| A1 | The old site keeps running until the new site is launched | Migration and the parallel period are disrupted |
| A2 | Diskominfo SP Sulsel provides the hosting environment (web application, database, file storage) and deployment is done directly on that server | Technology choices and NFR-09 and NFR-10 must be adjusted |
| A3 | Humas, Secretariat, and PPID staff are willing to use the new admin panel and attend one training session | Content is not updated after launch |
| A4 | Content that is currently images is migrated as is; the agency converts it to text gradually | FR-09 is not completed |
| A5 | The figures in this document come from observation of the public site on 21 October 2026; the old admin panel was not observed | Requirements with status Existing (presumed) may shift after the admin panel is examined |

### **10.3 Dependencies on partners**

The work requires the following from partners.

|  |  |  |
| :-: | :-: | :-: |
| Party | What is needed | Related |
| Diskominfo SP Sulsel | Hosting environment and direct deployment access on the server; specifications (operating system, CPU and RAM, database), CI/CD access, and a staging environment | A2, OQ-04 |
| Diskominfo SP Sulsel | Export of the old site's database and /content folder | OQ-01 |
| Diskominfo SP Sulsel | Official SMTP for notification emails | OQ-11, FR-23 |
| Diskominfo SP Sulsel and PPID | Official upload types and sizes, including the status of .zip and .rar | OQ-12, NFR-06 |
| Diskominfo SP Sulsel and Bappelitbangda | The date the old site is shut down, and a decision on whether surveys and polls stay on the old site until FR-25 to FR-27 are complete | OQ-13, A1 |
| PPID Bappelitbangda | The purpose of, and the person responsible for following up, the current form data; deadlines for responding to objections and complaints; the decision on the KTP field; data retention period and handling of data subject requests (OQ-15); review of the data use notice text | OQ-02, OQ-03, NFR-08 |
| Secretariat and PPID | Approval of the mapping of the 71 old document categories to the new taxonomy | OQ-08, FR-17 |
| Humas Bappelitbangda | Decision on the Photo and Video menu and on merging the Articles and congratulatory categories into News | OQ-09 |
| Bappelitbangda | Text or data for image-based content (organizational structure, officials' profiles, statistics tables), converted gradually by the agency | OQ-06, A4 |
| Bappelitbangda | Decisions on the Activity Calendar and Prayer Times, the mapping of the 35 cloned pages, and the manager and approval flow of the old admin panel | OQ-05, OQ-07, OQ-10 |
| Humas, Secretariat, and PPID staff | Willingness to use the new admin panel and attend one training session | A3 |
| Diskominfo SP Sulsel (cryptography unit, persandian) | The cryptographic standard, TLS certificate, and key storage that the agency requires; two holders of the personal data encryption key | OQ-16, OQ-17, NFR-17 |

## **11. Open Questions**

Seventeen matters have not yet been decided and affect the requirements above. The Decider column shows the party asked to answer.

|  |  |  |  |
| :-: | :-: | :-: | :-: |
| ID | Question | Affects | Decider |
| OQ-01 | Can Diskominfo provide an export of the old site's database and /content folder? | NFR-12 | Diskominfo |
| OQ-02 | Where does the data of the three PPID forms go now (email, database, other system), who follows it up, and what is the response deadline for objections and complaints? | FR-20 to FR-24 | PPID Bappelitbangda |
| OQ-03 | Does the "KTP" field contain a number or a file upload, does it actually need to be collected, and if not, is the field removed from the form (captcha is now a requirement, NFR-07)? | FR-20, NFR-08 | PPID Bappelitbangda |
| OQ-04 | Hosting specification: operating system, CPU and RAM, available database, CI/CD access, staging environment, and SMTP? | NFR-09, NFR-10, technology selection | Diskominfo |
| OQ-05 | Are the Activity Calendar and Prayer Times kept? What is the source of the calendar agenda? | FR-30, FR-31 | Bappelitbangda |
| OQ-06 | Who provides the text or data for image-based content (organizational structure, officials' profiles, statistics tables)? | FR-09, T-01 | Bappelitbangda |
| OQ-07 | Of the 35 cloned pages per period, which are migrated as separate archives and which are merged into versioned series? | FR-06 | Bappelitbangda |
| OQ-08 | May the 71 document categories be grouped into a hierarchy, and may the six categories with under 100 downloads (Governor Regulations, IKU, Food and Nutrition, Statistical Data, Staffing, Regional Spatial Plan) be merged? | FR-17 | Secretariat and PPID |
| OQ-09 | The Photo and Video menus are empty: are they removed or will they be filled? Are the Articles category (12 posts) and the three congratulatory categories merged into News with tags? | FR-10, FR-14 | Humas |
| OQ-10 | Who manages the old admin panel, and is there an approval before publication? | FR-33 | Bappelitbangda |
| OQ-11 | Is an official SMTP available for notification emails? | FR-23 | Diskominfo |
| OQ-12 | Official upload types and sizes, including whether .zip and .rar remain in use for complaint evidence? | FR-22, NFR-06 | Diskominfo and PPID |
| OQ-13 | When is the old site shut down, and do surveys and polls stay on the old site until FR-25 to FR-27 are complete? | FR-25 to FR-27, FR-41 | Diskominfo and Bappelitbangda |
| OQ-14 | What scope is committed for the implementation period (three months from 19 October 2026): MVP only (28 Must functional and 12 Must non-functional requirements), or MVP plus Phase 2 (12 Should functional requirements)? | Section 9, C-5 | Bappelitbangda, Diskominfo, and the development team |
| OQ-15 | What is the retention period for the personal data of applicants and complainants, and how are access, correction, or deletion requests from data subjects handled? | NFR-08 | PPID Bappelitbangda |
| OQ-16 | Is there a cryptographic standard, TLS certificate, or key storage that the agency requires (for example from the Diskominfo cryptography unit or BSSN)? | NFR-05, NFR-17 | Diskominfo |
| OQ-17 | Who are the two holders of the personal data encryption key (one of them a Diskominfo official), and where is a copy of the key stored outside the application server? | NFR-17 | Diskominfo and Bappelitbangda |

## **12. Acceptance Criteria and Handover**

The MVP is declared accepted when all Must requirements pass their acceptance criteria in the staging environment with fully migrated data. The proposed accepting parties are Bappelitbangda (function and content) and Diskominfo SP Sulsel (deployment on the server).

### **12.1 MVP acceptance conditions**

1.  The 28 Must functional requirements pass their respective acceptance criteria (Section 6).
2.  The 12 Must non-functional requirements meet their targets using the measurement protocol in Section 8.1.
3.  Migration reconciliation: content counts match the source (difference of 0), missing document files 0, 5% random sample match of 98% or more, and all mismatches fixed (NFR-12).
4.  One backup restore test succeeds on staging before release (NFR-10).
5.  Security scan with no High or Critical findings (NFR-05).
6.  All old URLs in Appendix A return 301 to the equivalent or 200 (FR-41, NFR-13).
7.  No severity 1 or 2 defects on Must requirement test scenarios (NFR-11).

### **12.2 Defect severity levels**

|  |  |  |
| :-: | :-: | :-: |
| Severity | Name | Definition |
| 1 | Critical | A core function cannot be used, data is lost, or personal data is exposed |
| 2 | High | A main function fails with no workaround |
| 3 | Medium | A function fails but a workaround exists, or the display is broken in one browser |
| 4 | Low | Cosmetic or a typo |

### **12.3 Deliverables**

  - Public site and admin panel running on the Diskominfo SP Sulsel server.
  - Migrated content of the old site, with the reconciliation report (NFR-12).
  - Redirects of old URLs, sitemap, robots, and metadata (FR-41, FR-42).
  - Admin panel user documentation and one officer training session (Section 4.1).
  - Technical documentation: API contract, versioned database schema, and a README that allows the system to be run locally (NFR-14, Should priority).

### **12.4 After release**

  - 30 days after release, old URLs are crawled again with the crawl script to verify NFR-13.
  - If traffic is sufficient, Chrome UX Report field data (28-day window) is compared with the NFR-01 targets.
  - Requirements with status Existing (presumed) are reviewed again after the old admin panel is examined (A5).
  - FR-40 is reviewed again after release (Section 4.2).

## **13. Approval**

By signing, the following parties approve this document as the basis of the work and agree that the Must requirements in Section 6 and Section 8 become the MVP scope. Changes to requirements after approval are recorded as a new version in the revision history, and requirement IDs are not renumbered.

|  |  |  |  |  |
| :-: | :-: | :-: | :-: | :-: |
| Role | Party | Name and position | Signature | Date |
| Product owner | Bappelitbangda of South Sulawesi Province |   |   |   |
| PPID service owner | PPID Bappelitbangda (FR-19 to FR-24, NFR-08) |   |   |   |
| Infrastructure provider | Diskominfo SP Sulsel (C-1, A2) |   |   |   |
| Author | Development team |   |   |   |

## **Appendices**

### **Appendix A. Old Site Inventory**

The inventory of the old site's pages, categories, and form fields is presented in a separate file, Lampiran\_A\_Inventaris\_Bappelitbangda.xlsx. Of the 137 inventory rows, the proposed decisions are keep 59, change 65, delete 2, and new 11. The URL list in that file is the reference for testing NFR-13.

|  |  |  |
| :-: | :-: | :-: |
| Worksheet | Contents | Rows |
| Summary (Ringkasan) | Automatic counts and observed figures | Not applicable |
| Page Inventory (Inventaris Halaman) | 108 menu entries, 20 pages and components outside the menu, and 9 new features | 137 |
| Document Categories (Kategori Dokumen) | 71 categories with downloads and proposed groups (not yet approved; OQ-08) | 71 |
| Publication Categories (Kategori Publikasi) | 10 categories with post counts | 10 |
| Forms (Formulir) | Fields of the three PPID forms, two surveys, and the contact form | 61 |

### **Appendix B. Glossary**

|  |  |
| :-: | :-: |
| Term | Meaning |
| Bappelitbangda | Regional Development Planning, Research and Development Agency of South Sulawesi Province (Badan Perencanaan Pembangunan, Penelitian dan Pengembangan Daerah Provinsi Sulawesi Selatan) |
| Diskominfo SP | Department of Communication, Informatics, Statistics and Cryptography of South Sulawesi Province (Dinas Komunikasi, Informatika, Statistik dan Persandian Provinsi Sulawesi Selatan) |
| PPID | Information and Documentation Management Officer (Pejabat Pengelola Informasi dan Dokumentasi) |
| UU KIP | Law Number 14 of 2008 on Public Information Disclosure (Undang-Undang Nomor 14 Tahun 2008 tentang Keterbukaan Informasi Publik) |
| OPD | Regional Apparatus Organization (Organisasi Perangkat Daerah) |
| SKM, IKM | Community Satisfaction Survey (Survei Kepuasan Masyarakat); Community Satisfaction Index (Indeks Kepuasan Masyarakat) |
| CMS | Content management system; in this document called the admin panel |
| MVP | Minimum launchable scope; consists of the Must requirements |
| MoSCoW | Priority scheme: Must (mandatory), Should (recommended), Could (optional), Won't (not done in this period) |
| WCAG | Web Content Accessibility Guidelines, the W3C's web accessibility guidelines |
| LCP, CLS, INP | Core Web Vitals: load time of the largest element, cumulative layout shift, and responsiveness to interaction |
| p75, p95 | The 75th and 95th percentiles of a set of measurements |
| RPO, RTO | The acceptable limit of data loss; the limit of service recovery time |
| Code 301 | HTTP code for a permanent redirect from an old URL to a new URL |
| Working days | Monday to Friday excluding national holidays and joint leave (cuti bersama) |
| Slug | The part of a URL that identifies a single page, for example a news title |
| Ticket | The registration number given to every PPID submission |
| Officer queue | The list of PPID submissions waiting for follow-up by the PPID Officer |
| Staging | A test environment configured identically to production |
| Deploy | Installing a new version of the application on the server |
| Canonical, Open Graph | Metadata that indicates the main address of a page for search engines and its display preview on social media |
| Hero | The main block at the top of the home page (FR-45) |
| Thumbnail | A small version of an image that is created automatically |
| Captcha | An automatic check that the sender of a form is a person, not a program; on this platform it is a computational challenge that runs in the browser without images or puzzles |
| AES-256-GCM | A standard encryption algorithm with a 256-bit key that also detects if data has been altered; used for stored personal data |
| argon2id | A password storage function that is deliberately slow and memory-intensive so that mass guessing is expensive |
| TOTP | A time-based one-time code from an authenticator app; the second factor when logging into the admin |
| Encryption key | The secret used to encrypt and open personal data; stored separately from the database and backups and held by two named people |

### **Appendix C. References**

|  |  |  |
| :-: | :-: | :-: |
| No | Reference | Used in |
| 1 | Law Number 14 of 2008 on Public Information Disclosure | FR-19 to FR-24; response period of 10 working days and extension of 7 working days (Article 22) |
| 2 | Law Number 27 of 2022 on Personal Data Protection | NFR-08 |
| 3 | Information Commission Regulation Number 1 of 2021 on Public Information Service Standards | FR-19 to FR-24 |
| 4 | Regulation of the Minister of State Apparatus Empowerment and Bureaucratic Reform (PANRB) Number 14 of 2017 on Guidelines for Preparing Community Satisfaction Surveys of Public Service Providers | FR-25 to FR-27 |
| 5 | Web Content Accessibility Guidelines (WCAG) 2.1, level AA | NFR-03 |
| 6 | Core Web Vitals (web.dev) | NFR-01 |
| 7 | OWASP Application Security Verification Standard (ASVS), levels 1 and 2 | NFR-05 |
| 8 | ISO/IEC 25010:2011, Product quality model | Classification of non-functional requirements (Section 8) |
| 9 | Appendix A, Old Site Inventory | Old site data; URL list for NFR-13 |
| 10 | ISO/IEC/IEEE 29148:2018, Requirements engineering | Document structure and quality of requirements writing (testable, traceable) |

Regulations are referenced at the level of title and the response period for information requests. Detailed application, including deadlines for objections and complaints, is confirmed together with PPID Bappelitbangda (OQ-02).

### **Appendix D. Technical Decisions**

Technical decisions that are hard to reverse are recorded here, with their reasons and the requirements they serve. There is no separate technical design document: before a module is built, the team writes a specification of 1 to 2 pages (data, API, interface, testing) that references the requirement IDs in this document, and new hard-to-reverse decisions are added as rows in the following table.

|  |  |  |  |
| :-: | :-: | :-: | :-: |
| Decision | Choice | Reason | Requirements |
| Back-end | Go, a single modular application (monolith) | Easy for a small team to operate and maintain; one process on one server | C-4, NFR-14 |
| Front-end | Svelte (SvelteKit); public pages rendered on the server, the admin panel runs in the browser | Content readable by search engines and screen readers without JavaScript | NFR-03, NFR-04 |
| Database | PostgreSQL, including text search; no separate search engine | One component to maintain; sufficient for 1,884 publications and 71 document categories | FR-04, FR-16, NFR-02 |
| File storage | Local server disk, outside executable directories | Single-server hosting (A2); no external storage service | NFR-06, NFR-10 |
| Deployment | Docker Compose on the Diskominfo server behind nginx; systemd if Docker is not available | Adjusts to the outcome of OQ-04 | C-1, A2, OQ-04 |
| API contract | OpenAPI 3.0.3 written first, code generated from it | Back-end and front-end work in parallel from day one | NFR-14 |
| Admin authentication | Server-side sessions, argon2id passwords, TOTP mandatory for Super Admin and PPID Officer, progressive login delay; built with standard libraries | Only about a dozen accounts and no public accounts; no separate identity service on the same server | FR-33, NFR-05 |
| Encryption | AES-256-GCM for KTP numbers, TOTP secrets, and attachments; HMAC-SHA-256 for markers; TLS 1.2 or higher; keys outside the database, repository, and backups, with two holders | Protects database dumps and backups. Limitation: a key on the same server does not protect if the application server itself is compromised | NFR-17, NFR-08 |
| Captcha | Self-hosted proof-of-work captcha, plus a honeypot and a submission limit per IP address | Does not depend on third parties, does not send visitor data outside, and does not demand a visual challenge from screen reader users. Limitation: raises the cost for bots, not an absolute safeguard | NFR-07, NFR-03 |
| Backup | Daily encrypted backup to a location outside the application server where available | Recovery of data and keys is tested before release | NFR-10, NFR-17 |
| Security testing | govulncheck, gosec, and OWASP ZAP scans in CI and staging; ASVS level 2 for the admin panel, authentication, and the PPID module | Personal data exists only in those modules | NFR-05 |

  
