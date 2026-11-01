# Port-Sight User Guide

> This guide covers everything you need to know to use Port-Sight day-to-day. It is written for network administrators and operations staff who are using the application — not for the people installing or maintaining the server itself. For installation, upgrades, backups, and other server-side topics, see the **Port-Sight Admin Guide**.

---

## Table of Contents

- [1. Welcome to Port-Sight](#1-welcome-to-port-sight)
- [2. Logging In](#2-logging-in)
- [3. The Dashboard](#3-the-dashboard)
- [4. Switches](#4-switches)
- [5. Interfaces](#5-interfaces)
- [Chapter 6a - Built-in Reports](#chapter-6a--built-in-reports)
- [Chapter 6b - Port Search and Report Builder](#chapter-6b--port-search-and-report-builder)
- [Chapter 7 - Tags, Labels, and Tag Rules](#chapter-7--tags-labels-and-tag-rules)
- [Chapter 8 - Polling](#chapter-8--polling)
- [9. Single Sign-On with SAML](#9-single-sign-on-with-saml-admin-only) **`Admin only`**
- [10. Network Maps](#10-network-maps)
- [11. Find Host](#11-find-host)
- [12. Capacity Trends](#12-capacity-trends)
- [13. SSH Terminal](#13-ssh-terminal)
- [14. Top Talkers](#14-top-talkers)
- [15. Link Events](#15-link-events)
- [16. Availability](#16-availability)
- [17. Outages](#17-outages)
- [18. The assistant](#18-the-assistant)
- [Glossary](#glossary)

---

## A note about admin features

Some Port-Sight features are only available to users with the **admin role**. Throughout this guide, those features are marked with the badge **`Admin only`** — both in the table of contents above and inline next to section headings.

If you do not have an admin account and need access to one of these features, contact whoever manages Port-Sight at your organization. You can confirm whether your account has admin access by going to the **Admin** section in the left sidebar — admin users see a full set of admin pages there (Switch Management, Tag Rules, Polling, etc.), while non-admin users won't see those options at all.

---

## 1. Welcome to Port-Sight

Port-Sight is a network switch port monitoring tool. It connects to your Cisco (and other vendor) switches over SNMP, regularly polls them for interface status, configuration, and traffic information, and gives you a single web dashboard to answer questions like:

- How many switch ports do we have, and how many are actually being used?
- Which ports have not been used in months and could be reclaimed?
- Are any ports reporting errors?
- Which switches are running out of capacity?
- Are any switches reloading unexpectedly?
- What firmware version is each switch running, and which ones are nearing end-of-life?

Port-Sight does **not** make any changes to your switches. It only reads from them via SNMP. You can think of it as a read-only monitoring overlay — there is no risk of Port-Sight pushing config or shutting down a port by accident.

### What's in this guide

This guide walks you through the main features of Port-Sight in the order that they will most likely matter to you:

- The **Dashboard** is where you land after signing in — a single-page overview of your environment. Most people spend most of their time here.
- The **Switches** and **Interfaces** chapters cover how to drill down into the details of any individual switch or port.
- The **Reports** chapter covers both the built-in reports (firmware, hardware, capacity, etc.) and the powerful **Report Builder**, which lets you write your own custom queries and save them.
- The **Tags and Site Tags** chapter explains how Port-Sight organizes switches into logical groups — by physical location, by site, by purpose, and so on.
- The **Polling** chapter (admin only) explains how the data behind everything else gets collected and how you can control when polling happens.
- The **Glossary** at the end defines terms used throughout the guide. If you ever encounter a phrase like "phantom port" or "last_changed_at" and aren't sure what it means, jump to the glossary.

### Some terms you'll see repeatedly

A few definitions worth introducing up front, since they will come up in almost every chapter:

- **Active port** — a port that has been operationally up at any point since the previous poll. If polling runs every four hours, "active" means the port was up at some point during that four-hour window. A port that briefly came up and went back down between polls still counts as active. Active is the *most current* of the three indicators — it reflects what has happened recently.
- **Used port** — a port that is currently up, *or* has had its operational state change at any point within the configured "days" threshold (commonly 30, 60, 90, or 120 days). "Used" looks back across a much wider window than "active" — a port that hasn't been touched for two months but had a device connected three months ago is still "used" for the purposes of capacity planning.
- **Unused port** — a port that has not had any operational state change within the threshold. These are candidates for reclamation.

The difference between "used" and "active" matters: a port can be "used" but not currently "active" if a device was connected last month and has since been unplugged. And a port can be "active" but not currently up if it briefly came up between polls. We'll come back to all of this in the Dashboard and Glossary chapters.

### Getting help

- **In the application** — click the Help link in the sidebar to open this guide on the Port-Sight website.
- **The Glossary** at the end of this guide defines every term we use.
- **The Admin Guide** (separate document) covers installation, upgrades, backups, troubleshooting, and other server-side topics.
- **Contact your Port-Sight administrator** for anything specific to your environment, including license issues, account creation, or feature access.

---


**Filter pills (v2.14.33).** Everywhere the app offers a row of filter pills — sites and tags, poll status, EoL, event severity and the rest — a **plain click shows only that pill** and clears every other pill on the page, including pills in other groups. Clicking the one pill that is already the only selection turns it off again. To **combine** pills — two sites, or Failed together with EoL Soon — hold **Ctrl** (Cmd on a Mac) while clicking. Checkboxes that pick rows to act on are not filters and still add up as you tick them.

## 2. Logging In

<!-- SCREENSHOT: login-page -- Port-Sight login screen with username, password fields, and the optional "Login with SSO" button if LDAP is configured -->

### First-time sign-in

When you visit the Port-Sight URL for the first time, you will see the login page. Enter the username and password your Port-Sight administrator gave you. If your organization has integrated Port-Sight with Active Directory, your normal AD credentials will work — your administrator will tell you whether to enter just `username` or the full `username@domain.com`.

If you are the very first user logging into a brand-new Port-Sight installation, you will see a one-time **setup wizard** instead of the login page. The setup wizard creates the first admin account. Whoever completes that wizard is automatically the application's first administrator. After the wizard finishes, the normal login page appears.

### Account types

Port-Sight has two kinds of accounts:

- **Local accounts** — created and managed inside Port-Sight itself. These have a username and a password stored in Port-Sight's own database. You can change your local password from inside the app.
- **LDAP / Active Directory accounts** — managed by your Active Directory environment. The password lives in AD, not Port-Sight, so you cannot change it from inside the app. To change an AD password, use whatever your organization's normal AD password change process is.

Your username is displayed at the **bottom of the left sidebar**, along with a **Change Password** link (local accounts only), a **Sign out** button, and the Port-Sight version number. Whether you have admin access is determined by what's visible in the navigation: admin users see an additional Admin section in the sidebar with options like Switch Management, Tag Rules, and Polling.

### Changing your password (local accounts)

> **Note:** This feature is only available for local accounts. If you signed in with an Active Directory account, the **Change Password** link will not appear in the sidebar — your password is managed by AD, not by Port-Sight.

To change your password:

1. Look at the bottom of the left sidebar — you should see your username followed by a **Change Password** link.
2. Click **Change Password**.
3. Enter your current password and your new password (twice).
4. Click **Save**.

You will not be signed out — your current session continues, but the next time you sign in you'll need the new password.

<!-- SCREENSHOT: change-password -- the change password dialog -->

### Session timeout

Port-Sight will automatically sign you out after a period of inactivity. By default this is **8 hours**, but your administrator can configure a different value. If you come back to the app after that window, you will be redirected to the login page and asked to sign in again. None of your work is lost — Port-Sight is read-only data viewing for the most part — and you can pick up right where you left off.

### If you cannot sign in

A few things to try if your login isn't working:

- **Double-check your username and password.** If your account is an AD account, make sure you're using the format your administrator told you (some organizations want `jsmith`, others want `jsmith@corp.com`).
- **Caps Lock.** Both username (sometimes) and password are case-sensitive.
- **Account locked or disabled.** If your administrator has disabled your account, no error message will tell you that specifically — it will just say your credentials are invalid. Contact your administrator if you're certain your password is correct.
- **The application is unreachable.** If the page won't even load, that's a server-side issue, not a login issue. Contact whoever administers the Port-Sight server for your organization.

### Signing out

To sign out, look at the bottom of the left sidebar and click **Sign out**. Your session is immediately terminated and you are returned to the login page. If you're using a shared workstation, this is the safest way to leave Port-Sight.

---

## 3. The Dashboard

The Dashboard is the page you land on every time you sign in. It is designed to give you the most important answers about your environment in a single screen, with shortcuts to drill into the underlying detail.

<!-- SCREENSHOT: dashboard-overview -- full Dashboard view with summary cards, top errors widget, top bandwidth widget, and the bottom Switch Reloads section visible. No filter applied. -->

### 3.1 The header bar

At the very top of the Dashboard you will see:

- The **page title** ("Dashboard").
- A **last campus poll** indicator showing the date and time of the most recent poll across your environment. If this says "Never" then no successful poll has happened yet — that usually means you've just installed Port-Sight, you have no switches added, or polling is failing. (See the **Polling** chapter and the Admin Guide for troubleshooting.)
- On the right side of the header, three controls:
  - A **Site tag filter** — explained in detail just below.
  - A **days threshold dropdown** — choose 30, 60, 90, 120, 180, 240, or 365 days. This controls the "looking back" window used by every metric on the Dashboard. (See the Glossary entry for **days threshold**.)
  - A **Poll All Switches** button **`Admin only`** — kicks off a poll across every active switch immediately. This is useful when you've just added or rewired something and don't want to wait for the next scheduled poll. The button is greyed out if your license is expired or invalid.

### 3.2 The site tag filter

Above the days dropdown sits the **site tag filter**, a row of coloured pills with site names on them. Each pill represents a site tag — a way of grouping switches by physical location, building, customer, or anything else you choose. (See the **Tags and Site Tags** chapter for how to set them up.)

Clicking a pill toggles the filter on or off. When one or more pills are selected:

- Every metric on the Dashboard is recalculated to include **only the switches in the selected sites**.
- The **Top Interface Errors** and **Top Bandwidth** widgets are filtered too.
- The **Switch Reloads** section is filtered.
- The **Low Port Availability** table only shows switches in the selected sites.
- The **Watched Reports** section is **not** filtered — saved reports run with their own conditions and are not affected by the dashboard filter.

If no pills are selected, the Dashboard shows everything.

> **Note:** The site tag filter only persists while you stay on the Dashboard page. If you navigate away and return, the filter is reset to "all sites." Set it again whenever you come back.

### 3.3 The four summary cards

<!-- SCREENSHOT: dashboard-stat-cards -- close-up of the four summary cards (Total Switches, Total Ports, Unused, % Unused), with the days dropdown set to 120 days -->

Below the header, the Dashboard shows four large summary cards that give you the at-a-glance numbers for your environment.

#### Total Switches

The number of **managed switches in inventory** — meaning switches that exist in Port-Sight and haven't been marked inactive. The smaller text below the number tells you how many of those have been polled successfully (`X polled successfully`). If the two numbers don't match, some switches are failing to poll.

Clicking this card takes you to the **Switch Management** page, where you can see and manage every switch.

> **Note:** This metric counts each managed switch as **one entry**, regardless of whether it is a standalone switch or a stack of multiple physical chassis. A stack of five 3850s, for example, counts as one in this number — Port-Sight manages the stack as a single SNMP target. To see the actual physical chassis count (every individual switch in every stack), go to the **Fleet Overview** report instead.

#### Total Ports

The total count of **physical Ethernet ports** across your environment, with **uplinks and excluded ports filtered out**. The "Physical; excludes uplinks & excluded ports" subtitle reminds you of this. Uplinks and excluded ports are not counted because they aren't candidates for end-user devices — they're infrastructure links between switches and shouldn't inflate your "available capacity" figure.

Clicking this card takes you to the **Switches** report, where you can see the same number broken down by switch.

> **Note:** Phantom ports — interfaces on empty network module slots, or alternate-tier interfaces on shared module slots — are also excluded. See the Glossary entry for [phantom port](#glossary).

#### Unused (≥ N days)

The headline number of **unused ports** — physical ports that have not had any operational state change within the selected days threshold. The header label updates to reflect your current selection (e.g., "Unused (≥120d)" if you have 120 days selected).

These are the ports you can most likely reclaim. They are not currently up, and they haven't been up at any point in the past N days, so it is reasonable to assume the device that used to be plugged in is gone.

Clicking this card opens the **Report Builder** with a pre-built query that lists every unused interface across your environment, filtered by the same days threshold and site tag selection. From there you can sort, filter further, and export the list.

#### % Unused

The percentage of physical ports that are unused — exactly `Unused ÷ Total Ports × 100`, rounded to one decimal. This is the headline capacity-planning metric. If you have a healthy environment with most ports in use, this number will be small (5–15%). If it's high (40%+), you have either a lot of overcapacity or a lot of unused ports that could be reclaimed.

Clicking this card takes you to the same Report Builder query as the Unused card.

### 3.4 Top Interface Errors

<!-- SCREENSHOT: dashboard-top-errors -- the Top Interface Errors widget showing 3-5 rows of interfaces with errors. Use a real switch with errors if possible. -->

If any interfaces in your environment are reporting errors, the **Top Interface Errors** widget appears below the summary cards. It shows the **top 5 interfaces** ranked by total errors, where "total" is the sum of input and output error counts since the last poll.

Each row shows:

- **Switch** — the switch name. Click to open the switch detail page.
- **Interface** — the interface name (e.g., `Gi1/0/24`). Click to open the interface detail page.
- **Description** — the interface description (`if_alias`), if one is set on the switch. This often contains the device name or location ("LL-013 Printer", "HSHSL-LL-AP07", etc.).
- **In** — input error delta since the last poll.
- **Out** — output error delta since the last poll.
- **Total** — sum of in + out, used for the ranking.

Some things to know about this widget:

- **Admin-down ports are excluded.** Some switch firmware reports phantom errors on ports that are administratively shut down. These would otherwise dominate this list and add no value, so they're filtered out.
- **Half-duplex ports are excluded.** Half-duplex Ethernet by definition has collision-related errors as a normal part of operation. They're filtered out for the same reason.
- **The widget is hidden entirely if there are no errors anywhere.** A clean environment has no widget — that's by design, not a bug.
- **The widget respects the site tag filter.** If you've selected a site tag, only interfaces on switches in that site are eligible.

> **Note:** The error counts shown here are **deltas since the last poll**, not lifetime totals. This makes the metric meaningful — a switch that has been online for two years will have huge lifetime error counters that don't tell you anything about *current* problems. Deltas tell you what's wrong right now.

### 3.5 Top Bandwidth Interfaces

<!-- SCREENSHOT: dashboard-top-bandwidth -- the Top Bandwidth Interfaces widget. If errors widget is also visible, capture both side by side. -->

To the right of (or below, depending on your screen width) the Top Errors widget is the **Top Bandwidth Interfaces** widget. It shows the **top 5 interfaces** by total bandwidth — the sum of inbound and outbound traffic since the last poll.

Each row shows:

- **Switch** — switch name (clickable).
- **Interface** — interface name (clickable).
- **Description** — the interface description.
- **In** — average inbound rate over the polling interval.
- **Out** — average outbound rate.
- **Total** — sum of in + out, used for the ranking.

Bandwidth is displayed in the most appropriate unit — Kbps, Mbps, or Gbps — based on the value. A 5 Gbps uplink will display as "5.0 Gbps", not "5,242,880 Kbps".

The widget is hidden if no interfaces have meaningful traffic. It also respects the site tag filter.

> **Note:** "Top bandwidth" usually means uplinks. Uplinks aren't filtered out of this widget the way they are from the Total Ports count — knowing which uplinks are getting the heaviest traffic is useful for capacity planning and identifying potential bottlenecks.

### 3.6 Watched Reports

<!-- SCREENSHOT: dashboard-watched-reports -- the Watched Reports section showing 3-6 saved report cards. Include at least one critical report (red) for contrast. -->

If you have any **saved reports** marked as favorites or critical, they appear in a dedicated section below the top errors and bandwidth widgets, with the heading **★ Watched Reports**.

Each card shows:

- The **report name** at the top. If the report is marked **critical**, a red exclamation icon appears before the name and the entire card has a red border and background tint.
- The **last count** — the number of rows the report returned the last time it was run. This is the headline metric. Color codes:
  - **Red** — critical reports always show their count in red, regardless of value.
  - **Cyan** — non-critical reports with a non-zero count.
  - **Green** — non-critical reports with a count of zero (which usually means "no problems found").
  - **Grey dash** — the report has not been run yet.
- The **last run** time on the right side.

Critical reports are always sorted to the top of the section. Non-critical reports follow.

**Reports with a count of zero are hidden from the dashboard entirely** — when there's nothing to look at, the card disappears. So a fully clean environment won't show any cards in this section.

To make a report appear here, go to the **Report Builder**, save a report, then click the gold star icon (favorite) or the red exclamation icon (critical) next to it. Click any card to jump straight to that report's results in the Report Builder.

> **What's the difference between favorite and critical?** Favorite means "I want this on the dashboard at a glance." Critical means the same thing, plus "this needs immediate attention" — it gets the red coloring and is sorted to the top. Use critical for things like "switches that failed to poll" or "ports with errors > 100." Use favorite for things you want to keep an eye on but aren't urgent.

### 3.7 Low Port Availability

<!-- SCREENSHOT: dashboard-low-availability -- the Low Port Availability table with 3-5 switches showing low free port percentages and the colored progress bars -->

Below the watched reports is the **Low Port Availability** table. It lists **switches that are running low on free ports** — specifically, switches where the percentage of free ports has dropped below your environment's **capacity growth threshold**. The default threshold is 20%, and the value is configurable by an admin under **Admin → App Settings**. The same settings page also lets you configure the **estimated cost of a 48-port switch**, which is used elsewhere in the capacity reports for budget planning.

The table shows:

- **Switch** — name (clickable to switch detail).
- **Location** — the switch's physical location, if set.
- **Free Ports** — number of currently free physical ports. (See the Glossary for how "free" is calculated.)
- **Total** — total physical ports on the switch.
- **% Free** — percentage of free ports, with a progress bar:
  - **Red** — less than 5% free (urgent).
  - **Orange** — 5-9% free (warning).
  - **Yellow** — 10% up to the threshold (informational).

A "Full Capacity Report" link in the top-right of the section takes you to the dedicated Capacity Report page, where you can see all switches (not just the low ones), apply more filters, and export the data.

The table is hidden entirely if no switches are below the threshold — that's good news.

> **Note:** Newly added switches do not appear in this list until they've been observed long enough for the data to be reliable. Specifically, if no interface on the switch has a state-change record older than the selected days threshold, the switch is skipped — there hasn't been enough time to draw meaningful "this port has been idle for X days" conclusions yet. Once the switch has been polled across the threshold window (e.g., 120 days for the default), it will start appearing here if it qualifies. This is **only** about new-switch onboarding — it does **not** affect switches that have been managed for a while and then reload. Port-Sight retains the full historical port-usage record across switch reloads, so a long-managed switch keeps its data even if it reboots.

> **Note:** "Free" here uses the same definition as the Total Ports metric in the summary cards — uplinks, excluded ports, and phantom ports are filtered out. "Used" includes any port that is currently up *or* has had a state change within the configured days threshold. So a switch where most ports were active a few months ago will not appear in this list, even if many of those ports are physically disconnected today.

### 3.8 Switch Reloads

<!-- SCREENSHOT: dashboard-switch-reloads-calendar -- the Switch Reloads section with a calendar view showing several days highlighted with reload events, plus the time-range button bar at the top -->

The bottom section of the Dashboard is the **Switch Reloads** view. This is where Port-Sight tells you which switches have rebooted recently and how often.

#### Detection

Port-Sight detects reloads automatically by watching the switch's **uptime counter**. Each time a switch is polled, its current uptime is recorded. When the next poll comes in and the uptime counter is *lower* than it was at the previous poll (which can only happen if the switch rebooted in between), Port-Sight registers that as a reload event. The "reloaded at" time is computed as the current poll time minus the new uptime, giving you a precise reload moment.

This detection requires no special configuration on the switch — it works on any device that exposes `sysUptime` via SNMP, which is essentially every managed switch ever made.

#### The time range buttons

Above the section, you can choose how far back to look: **24h**, **3 days**, **7 days**, **30 days**, or **90 days**. The default is 90 days. Changing the time range updates everything in this section: the calendar, the frequent reloaders, and the events table.

The header also shows two summary numbers: total reloads in the period, and the number of distinct switches that reloaded.

#### Frequent Reloaders banner **`Admin only` action**

If any single switch has reloaded **3 or more times** within the selected period, a yellow warning banner appears listing those switches as **Frequent Reloaders**. Each switch is shown as a clickable pill with a count (e.g., `SwitchName (4x)`).

If you are signed in as an admin, each pill has a small **✕** dismiss button next to it. Clicking dismiss tells Port-Sight that you've acknowledged this switch's recent reloads — the banner will hide that switch immediately. If the switch reloads again later (enough times to hit the 3+ threshold *after* the acknowledgment), it will reappear in the banner. This way you can clear out known-noisy or recently-rebooted-on-purpose switches without permanently silencing them.

Non-admin users see the pills but no dismiss buttons.

#### The calendar

The main visual is a **calendar view**, broken into one or more month tiles depending on the time range you've selected (90 days = 4 months, 30 days = 1-2 months, etc.). Each day is colored based on how many reload events happened on that day:

- **Red** — 5 or more reloads on this day (severe).
- **Orange** — 3-4 reloads.
- **Yellow** — 1-2 reloads.
- **Grey/dim** — no reloads.

Today is highlighted with a faint outline.

Clicking a day with reload events filters the events table below to show only that day's reloads. A "Clear date filter" button appears at the top right of the calendar section so you can return to the full view.

#### The events table

Below the calendar is a table of individual reload events. By default it shows the most recent 20 events. If you click a calendar day, the table filters to that day instead.

Each row shows:

- **Switch** — name (clickable). Switches in the frequent reloaders list also get a small `Nx` badge here in red.
- **IP Address** — the switch's management IP.
- **Reloaded At** — when the reload happened (computed from the uptime counter).
- **Uptime After** — how long the switch has been up since the reload (e.g., "5d 2h").
- **Location** — physical location, if set.
- **Model** — switch model.

> **Note:** A reload is not always a problem. Switches may be rebooted intentionally for upgrades, configuration changes, or maintenance. The point of this view is **awareness** — if you didn't reboot a switch and it appears here, that's something to investigate. Switches that reload repeatedly (the frequent reloaders) are usually the most concerning.

### 3.9 Tying it all together

The Dashboard is meant to be your daily starting point. A typical workflow might look like:

1. **Glance at the four summary cards.** Are any numbers surprising? Has the unused count jumped overnight?
2. **Look at the Top Errors widget.** If it's empty, your interfaces are clean. If it has rows, click into the worst offender to see history and decide if it needs attention.
3. **Scan the watched reports.** Anything red? Any non-zero counts that demand investigation?
4. **Check Low Port Availability.** Are any switches running out of room? If so, that's a planning conversation, not a same-day fix.
5. **Look at the Switch Reloads calendar.** Are there any unexpected reload events? Any frequent reloaders?

If everything looks fine, close the tab and get on with your day. The Dashboard is designed to be **actionable** — if you don't see anything alarming, there is nothing alarming.

---

## 4. Switches

The **Switches** page is the second main pillar of Port-Sight, alongside the Dashboard. Where the Dashboard shows you environment-wide totals, the Switches page lets you dig into the per-switch numbers — and from any row, drill into the full details of an individual switch and its interfaces.

You'll get to the Switches page in one of two ways:

- Click **Switches** in the left sidebar.
- Click the **Total Ports** Dashboard summary card. The **Unused** and **% Unused** cards do *not* land here — they take you to the Report Builder with a pre-built unused-interfaces query instead.

### 4.1 Switches list overview

<!-- SCREENSHOT: switches-list -- full Switches page with the days threshold dropdown, label filter, checkbox filters, and a few rows visible -->

The Switches list is the per-switch view of capacity. Each row represents one **managed switch** (or stack — see the note at the end of Section 3.3 about how stacks count) and shows its key port-utilization metrics in one place.

The columns are:

- **Switch Name** — the name Port-Sight stores for this switch. Click any row to open the [switch detail page](#43-the-switch-detail-page).
- **IP Address** — the management IP Port-Sight uses to poll the switch.
- **Location** — a free-form text label you set inside Port-Sight when you add or edit the switch. Port-Sight does **not** read this from SNMP; it's an optional field you can use however you like (building name, room number, rack, anything).
- **Total Ports** — the number of physical Ethernet ports on this switch, with uplinks/excluded/phantom ports filtered or included according to the checkbox filters described below.
- **Peak Active** — the highest number of ports that were ever simultaneously *active* on this switch within the selected days threshold. This is the high-water mark and is the most useful number for capacity planning. (See [active port](#glossary) in the Glossary.)
- **Used** — the number of ports counted as currently used. This uses the same definition as the Dashboard: currently up *or* state-changed within the days threshold.
- **Unused** — total minus used. The candidates for reclamation on this switch.
- **% Unused** — unused divided by total, shown with a colored badge. Higher percentages get more attention-grabbing colors.
- **Last Polled** — the timestamp of the most recent successful poll. A red `✗` next to the timestamp means the most recent poll attempt failed.
- **Last Reload** — the timestamp of the switch's last reboot. The text turns **red** if the reload is *older* than the days threshold (the switch has been stable for a long time). Recent reloads stay in the default gray.

Click any column header to sort by that column. Click again to flip the sort direction.

### 4.2 Filters

The header above the table holds several filter controls:

#### Days threshold

The same days dropdown you saw on the Dashboard. Choices are 30, 60, 90, 120, 180, 240 days, **All Time**, or **Custom**. Choosing Custom lets you type any number of days. Whatever you choose here is remembered between page visits and shared with the Dashboard.

> **Note:** The "All Time" choice means used ports include any port that has ever been up — there is no time limit. This will produce the *lowest* unused count, since any port that was ever connected counts as used. Use this when you want a "what is this switch ever capable of being used for" view rather than a "what is currently being used" view.

#### Label filter (site tags)

A row of pills representing site tags (and potentially other switch labels). Click pills to filter the list to switches in those sites only. Unlike the Dashboard, this filter **persists in the page URL** — meaning you can bookmark a filtered view and share it.

#### Uplinks / Excluded / Admin-down checkboxes

Three independent toggles that control which interfaces are included in the per-switch counts:

- **Uplinks** — when checked, interfaces tagged as uplinks are counted toward Total / Used / Unused. Default: **on**. Most environments want uplinks counted as part of the switch's capacity even though they aren't candidates for end-user devices.
- **Excluded** — when checked, interfaces tagged as excluded are counted. Default: **off**. The "exclude" tag is meant to remove certain ports entirely from capacity counting (phantom interfaces, infrastructure links you don't want to track, etc.).
- **Admin-down** — when checked, interfaces that are administratively shut down on the switch are counted. Default: **on**. Many admins use admin-down as a "this port is unused but reserved" marker, so leaving them in the count keeps the capacity numbers accurate.

> **Tip:** If your "Total Ports" and "Used" numbers don't match what you expect, the first thing to check is these checkboxes. The combinations of uplinks/excluded/admin-down can shift the numbers significantly.

### 4.3 The switch detail page

Click any switch name in the list to open its **detail page**. This is where you see every interface on the switch in one big sortable, filterable table.

<!-- SCREENSHOT: switch-detail -- switch detail page header showing switch name, IP, location, model, last polled, last reload, plus the tab bar and the interface table beneath -->

#### The header

At the very top of the detail page, you'll see:

- **Switch name** as the page title.
- A **back button** to return to where you came from.
- **"N hidden by filters · Show all"** above the table when a filter or the reserved `exclude` tag is hiding interfaces; Show all clears every filter at once. Hover a tag chip on any interface to see who or which rule assigned it, and when.
- **"N no longer on this switch · show"** when the switch has stopped reporting some ports (a FEX, line card or stack member removed). They count toward nothing — not capacity, not unused ports, not VLAN counts — and stay folded away until you click *show*, where they appear dimmed with a small *gone* mark; they come back on their own if the hardware returns.
- An **SSH** button **`Admin only`** next to the IP address — opens a terminal to this switch in a new browser tab (see Chapter 13).
- A **Poll now** button **`Admin only`** — triggers an immediate poll of just this one switch. Useful when you've just made a change on the switch and want to refresh Port-Sight without waiting for the next scheduled poll.
- A row of switch metadata: **IP address**, **location**, **model**, **last polled** (with relative time), and **last reload** (with relative time). The reload text is color-coded based on how recently the switch rebooted: **green** if the reload happened within the selected days threshold (recent), **red** if the reload is older than the threshold.

#### The tab bar

Below the header is a small tab bar that lets you switch between different views of the same switch:

- **Port Detail** — the default view, an interface-by-interface table (described below). This is what you'll use 95% of the time.
- **Usage Trend** — a graph showing how active/used/total port counts have changed over time. See the [Reports](#6-reports-coming-soon) chapter for how to read it. The **Capacity Current** figures and the recommended size under the graph use the latest reading’s **Used** count, which is the same figure the Capacity Report shows, so the two pages agree (v2.15.16). A port counts as used if it is currently active (admin up + oper up) OR if its last state change falls within the **Days Threshold**; a change Port-Sight itself observes between two polls counts even when the switch’s own last-change counter did not move (v2.15.18). **Peak Active** is the highest up count inside the threshold window and **Active now** is the latest poll; the tile labels carry the threshold you have set. One thing to know when reading the graph: a reload resets every port’s last-changed time, so for one threshold window after a reload every port counts as used, which draws a plateau that ends in a cliff exactly one threshold after the reload. The page says so under the graph when the readings in that span show it. A supervisor failover restarts the uptime counter without taking any port down, so “last reload” moves but no plateau appears, and the note stays away.
- **Switch View** — a graphical visualization of the switch's physical layout, showing each port as a colored cell. Useful for visualizing rack layouts. Only appears for switches whose model has a model definition in Port-Sight (most Cisco models do).
- **Hardware** — chassis, modules, power supplies, and fans for this switch, populated by the hardware inventory polling. Useful for asset management and identifying installed network modules.

#### When the hardware changes **`Admin only`**

Every poll compares the switch's chassis serial numbers with what Port-Sight last saw. Stack members are identified by their own serials: Cisco stacks report one per member, and Dell N-series stacks, which report the current master's serial on every member, are read from Dell's per-unit table instead, so a reload that elects a different master is not a change. A change seen on two polls in a row (one sighting could be a bad read) pauses polling for that switch and shows an amber banner on this page — *Whole chassis swap*, *Stack member removed*, *Stack member replaced (RMA)* or *Stack composition changed* — with the serials kept, removed and added. You choose what the change means:

- **Keep the data, retire what is gone** — for a member deliberately removed (a FEX unplugged from a Nexus, a stack member pulled) while the rest is the box you know. Nothing is deleted and the asset tag stays; a poll runs right away and the ports it no longer finds are marked *no longer on this switch* — left out of capacity, unused-port and VLAN counts, folded away in the table below, and brought back automatically if the hardware ever returns.
- **Archive old, create new entry** — the switch was replaced by different hardware. The old record is archived with all its history; a new entry with the same name, IP and SNMP settings starts fresh (the asset tag is not carried over).
- **Purge data, keep this switch entry** — the same entry, but every interface, poll history and component change history for it is **deleted** and polling starts over. Use this only when the old data is worthless.
- **Acknowledge as RMA, keep data** — offered for a like-for-like swap: the new serials are accepted and nothing else changes.

Ports can also go missing without a serial change — a line card pulled from a modular chassis, say. Port-Sight retires those on its own once two polls in a row have not seen them, so a port that drops out of one bad table walk is never hidden by mistake.

#### Interface filters

Above the interface table is a row of filter controls:

- **Search box** — filter the table by interface name, description (alias), VLAN, or notes. Supports both plain text matching and regex patterns. If you type something that's not a valid regex, it falls back to plain text.
- **Days threshold dropdown** — same as on the Switches list. Affects what counts as "used" when computing the per-row "Last Used" age.
- **Uplinks / Excluded / Admin-down checkboxes** — same as on the Switches list, applied to which rows are shown in the table.
- **Show only unused** — a more aggressive filter that hides everything *except* unused ports. Useful when you want a quick "which ports on this switch could be reclaimed?" view.
- **Reclaim Report** button — opens the **Reclaim Report** for this switch, which is a printable list of ports that have been idle long enough to be candidates for decommissioning. See the [Reports](#6-reports-coming-soon) chapter.
- **Export CSV** — exports the currently visible interface list to a CSV file you can open in Excel or share with colleagues.

#### Interface table

Below the filters, the table shows every interface on the switch. The columns include:

- **Interface** — the interface name (e.g., `Gi1/0/24`). Click to open the [interface detail page](#5-interfaces-coming-soon) for that single interface.
- **Description (alias)** — the description set on the switch via `description` or `if_alias`. This often contains the device name, location, or purpose.
- **Mode** — whether the interface is access or trunk.
- **VLAN** — the access VLAN, or `trunk` if it's a trunk port.
- **Speed** — the interface speed (e.g., `1G`, `10G`). Half-duplex ports show `HD` next to the speed in yellow as a warning.
- **Admin** — administrative status (Up / Down).
- **Oper** — operational status (Up / Down).
- **Last Used** — when the interface last had an operational state change.
- **Age** — how long ago the last state change was, shown in human-friendly units. "Active" appears here for currently-up ports.
- **Traffic** — average inbound/outbound bandwidth from the most recent poll, formatted with appropriate units (Kbps/Mbps/Gbps).
- **Errors** — input/output error deltas from the most recent poll. Highlighted in red if non-zero.
- **Tags** — colored tag pills for any tags assigned to this interface (uplink, exclude, wifi-ap, custom user tags, etc.).
- **Notes** — free-form notes attached to the interface.

Click any interface name to drill into the [interface detail page](#5-interfaces-coming-soon), which has its own bandwidth and error history charts.

#### Show only: tag filter bar

If your environment has interface tags (uplink, wifi-ap, custom user tags, etc.), a small **Show only:** bar appears below the main filter row. Each tag is shown as a clickable colored pill. Clicking a pill activates that tag — only interfaces with that tag remain visible. You can click multiple tags to show interfaces tagged with **any** of them. Click an active pill again to turn it off, or click anywhere outside the pills to clear all filters.

This is the fastest way to answer questions like "which ports on this switch are wifi access points?" or "which ports are tagged as patch panel infrastructure?"

### 4.4 Adding switches **`Admin only`**

<!-- SCREENSHOT: switch-management-add -- Switch Management page with the Add Switch dialog open showing all the SNMPv2c and SNMPv3 fields -->

**Before you add a switch** — three lines on the switch itself make everything Port-Sight does more reliable, and the Add Switch dialog lists them under *Three switch settings worth having first*:

- `snmp-server ifindex persist` — keeps the interface numbers Port-Sight identifies every port by stable across reloads (Catalyst 9000 does this by default; older IOS switches do not).
- `snmp ifmib ifalias long` — lets long port descriptions arrive whole instead of cut off.
- `snmp-server group <v3-group> v3 priv context vlan- match prefix` — on IOS-XE with SNMPv3, lets Port-Sight read the MAC table of every VLAN, which Find Host and Top Talkers rely on (chapter 11). `<v3-group>` is the group your Port-Sight user is in; `v3 auth` works there too.


To add a switch to Port-Sight, you need an admin account. Go to **Admin → Switch Management** in the left sidebar. From there:

1. Click **+ Add Switch**.
2. Fill in the basic info: **Name** (any descriptive label), **IP Address** (the management IP), and optionally **Location**, **Asset Tag**, and **Site Tag**.
3. Choose the **SNMP version** — Port-Sight supports both **SNMPv2c** (community string) and **SNMPv3** (username + auth + priv).
   - For **SNMPv2c**, enter the **community string** the switch is configured with.
   - For **SNMPv3**, enter the **username**, **auth protocol** (usually SHA), **auth password**, **priv protocol** (usually AES), and **priv password**. All credentials are encrypted at rest using your installation's encryption key.
4. Click **Save**.

Port-Sight will attempt to poll the new switch immediately. If the credentials are correct, the switch will appear in the list with a green status indicator within a few seconds. If the poll fails, the switch is still added but you'll see a red ✗ next to its status — check the credentials and try clicking **Poll** to retry.

#### Bulk add

If you're adding many switches at once, click **Bulk Add** instead of the regular **Add Switch** button. The Bulk Add dialog has **two tabs**, each suited to a different scenario.

<!-- SCREENSHOT: switch-management-bulk-add -- Bulk Add dialog with the IP Range tab visible, showing the SNMP credentials section and the Start IP / End IP fields -->

##### Method 1: IP Range

The first tab, **IP Range**, lets you scan a contiguous block of IP addresses and add every switch found within it. Use this when all your switches share the same SNMP credentials and live on the same subnet (or a sequential block).

1. Enter the **SNMP credentials** at the top of the dialog. These will be applied to every switch added in this batch.
2. Optionally enter a **Location**, **Asset Tag**, and **Site Tag** — these are also applied to every switch in the batch. Most users leave these blank for the IP Range method and update them per-switch afterward.
3. Enter a **Start IP** and **End IP** for the range you want to scan.
4. Click **Preview Range**. Port-Sight will list every IP address in the range so you can review what's about to be added (max 1024 IPs per import).
5. Click **Add** to attempt adding each one. Port-Sight will try to poll every IP in the list using your shared credentials. IPs that successfully poll are added; IPs that don't respond or fail authentication are reported as "Failed" in the summary.

This is the fastest method for **greenfield setups** — point Port-Sight at a known management subnet, walk away, and let it discover everything that responds.

##### Method 2: CSV Import

<!-- SCREENSHOT: switch-management-bulk-csv -- Bulk Add dialog with the CSV Import tab visible, showing the Download Template and Upload CSV buttons -->

The second tab, **CSV Import**, lets you upload a spreadsheet of switches with per-row metadata and (optionally) per-row SNMP credentials. Use this when:

- Your switches have different SNMP credentials (some v2c, some v3, different communities or usernames).
- You already have an inventory in a CMDB or spreadsheet that you want to import as-is.
- You want to set per-switch locations, asset tags, and site tags during the import.

The workflow:

1. Click **Download Template** to get a starter CSV file (`switch-import-template.csv`). The template includes the column headers and two example rows (one v3, one v2c) showing the expected format.
2. Open the file in Excel, Google Sheets, or any text editor and add your switches. The columns are:
   - `ip_address` (required)
   - `location`, `asset_tag`, `site_tag` (optional metadata)
   - `snmp_port` (optional, defaults to 161)
   - `snmp_version` (`2c` or `3`)
   - `snmp_community` (v2c only)
   - `snmp_username`, `snmp_auth_protocol`, `snmp_auth_password`, `snmp_priv_protocol`, `snmp_priv_password` (v3 only)
3. Optionally, set the **shared SNMP credentials** at the top of the dialog. These act as a **fallback** for any rows in your CSV that don't include their own credentials. If a row in the CSV has its own `snmp_version` value, that row uses its own credentials; otherwise it uses the shared ones.
4. Click **Upload CSV** and select your file. Port-Sight will parse it and show you a preview table — IP, location, asset tag, and which credentials each row will use (per-row `v3`/`v2c` in cyan, or "shared" in gray if falling back).
5. Click **Add** to commit the import.

##### After the import

Both methods finish on the same summary screen:

- **Added** — switches that were successfully created and polled.
- **Skipped** — switches that already existed in Port-Sight (duplicate IPs are detected and silently skipped).
- **Failed** — switches that couldn't be added or polled. The detail table shows the reason for each failure (no response, authentication error, etc.).

If any rows had an unrecognized site tag name, they're added without a site tag and you'll see a yellow warning telling you to fix the tag name in **Admin → Tags**.

#### Removing a switch

To remove a switch entirely, click the **Delete** button on its row. This permanently removes the switch and all of its historical poll data. You will be prompted to confirm before the switch is actually removed.

> **Note:** Deleting a switch is currently the only way to take a switch out of polling. There is no "pause polling" or "archive" option in the user interface. If you need to keep a switch in inventory through a temporary outage, the best workaround is to leave it as-is — the failed-poll indicator will appear until the switch comes back online.

### 4.5 Tying it all together

The Switches view answers two distinct questions:

1. **"Which switches need attention?"** — Use the Switches list. Sort by `% Unused` to find switches with the most reclaimable capacity, or sort by `Last Reload` to find recently rebooted switches that need investigation.
2. **"What's going on with this specific switch?"** — Click into a switch row to see every interface. Use the search box, the show-only filters, and the tabs (Port Detail, Usage Trend, Switch View, Hardware) to drill in.

If you're an admin, the **Switch Management** page is where you add, edit, or remove switches. Day-to-day, most of your time will be spent in the Switches list and the switch detail page.

---

## 5. Interfaces

The **Interface Detail page** shows everything Port-Sight knows about a single interface (a single switch port). It is your deepest level of detail — beyond this point, the only thing more granular is the SNMP MIB itself. This is where you go when you want to answer questions like:

- Why is this port reporting errors?
- What's the bandwidth pattern look like over the past month?
- When was this port last used, and by what?
- Is this port half-duplex (which would explain the errors)?
- What is the actual configured speed and current operational state?

You'll get to this page by **clicking any interface name** on the [Switch Detail page](#43-the-switch-detail-page), the [Port Search page](#6-reports-coming-soon), the [Report Builder](#6-reports-coming-soon), or any of the dashboard widgets that show interfaces (Top Errors, Top Bandwidth).

### 5.1 Page layout overview

<!-- SCREENSHOT: interface-detail-overview -- full Interface Detail page showing the header with switch link, status badges, six stat cards, bandwidth chart, error chart (if applicable), and the Details grid below -->

The Interface Detail page is laid out vertically in five main sections, top to bottom:

1. **Header** — interface name, switch name (clickable link back to the switch), description, and a period-selector for the charts.
2. **Switch info row** — IP address, location, model, and last polled time of the parent switch.
3. **Status badges** — current operational status, speed, duplex, VLAN, port mode (access/trunk).
4. **Stat cards** — six cards showing current bandwidth, lifetime average bandwidth, and error counts.
5. **Charts and Details** — a bandwidth time-series chart, an error chart (if errors exist), and a key/value Details grid at the bottom.

Let's walk through each section.

### 5.2 The header

<!-- SCREENSHOT: interface-detail-header -- close-up of the header showing the interface name as the page title, the switch name as a clickable link beneath it, and the period selector buttons (7d / 14d / 30d / 60d / 90d) -->

At the very top:

- **Page title** — the interface name as it appears on the switch (e.g., `GigabitEthernet1/0/24`).
- **Subtitle** — the switch name as a **clickable link** that takes you back to the switch detail page, followed by the interface description (the `if_alias` set on the switch via the `description` command, if one exists). If there's no description, just the switch name appears.
- **Period selector** — a row of buttons (`7d`, `14d`, `30d`, `60d`, `90d`) on the right side. The selected period controls how far back the bandwidth and error charts look. The default is 30 days. Click any button to change the period — the charts re-render immediately.

Below the header is the **Switch info row**, the same one you see on the Switch Detail page header: IP address, location, model, last poll time. This is here so you have the parent switch's context without having to navigate back.

### 5.3 Status badges

A row of small colored badges showing the current state of the interface:

- **Up / Down** — operational status. Green badge if up, red badge if down.
- **Speed** — current line speed (e.g., `1G`, `10G`, `100M`). Followed by `FD` (full duplex) or `HD` (half duplex) if duplex info is available.
- **Half Duplex warning badge** — if the interface is operating at half duplex, an additional yellow "Half Duplex" badge appears. Half duplex is almost always a misconfiguration on modern equipment and is a common cause of error spikes — the badge is meant to make the situation visually obvious.
- **VLAN** — the access VLAN ID (e.g., `VLAN 100`).
- **Port mode** — `access` or `trunk`.

> **Note:** If you see the Half Duplex badge and the port is also reporting errors in the [Top Interface Errors](#34-top-interface-errors) widget on the dashboard, the errors are *expected* — half-duplex Ethernet by definition has collision-related errors as part of normal operation. This is one of the reasons Port-Sight excludes half-duplex ports from the dashboard's Top Errors widget.

### 5.4 Stat cards

<!-- SCREENSHOT: interface-detail-stat-cards -- close-up of the six stat cards showing Last Poll In, Last Poll Out, Avg In (since boot), Avg Out (since boot), In Errors (last poll), Out Errors (last poll). Use a port with real traffic. -->

Six cards across the middle of the page. Each shows a single metric:

#### Last Poll In / Last Poll Out

The bandwidth rate measured between the most recent poll and the one before it. This is the **average** rate over that polling interval (typically a few hours), not an instantaneous measurement. Numbers are displayed in human-friendly units — Kbps, Mbps, or Gbps — depending on the magnitude.

If you see `0 Kbps` here, it means no traffic moved across the interface during the most recent polling window.

#### Avg In / Avg Out (since boot)

The lifetime average bandwidth rate calculated from the switch's reported uptime and total octet counters. This is `total_octets / uptime` — a coarse, very long-term average that smooths out everything.

These numbers are most useful for understanding the *baseline* of an interface — a port that consistently moves an average of 5 Mbps year-round looks very different from one that moves 50 Mbps on average.

> **Note:** Lifetime averages reset when the switch reboots, since the octet counters and uptime both restart from zero. So a switch that just rebooted will show very low lifetime averages until enough traffic accumulates again.

#### In Errors / Out Errors (last poll)

The number of new errors counted **between the most recent poll and the one before it** — i.e., the delta, not the lifetime total. The card shows the delta as the headline number, with the lifetime total in smaller text below as `Total: NNN`.

If the delta is greater than zero, the card is highlighted in **red**. If it's zero, the card is normal-colored. This makes it easy to spot freshly active error sources at a glance.

> **Why deltas instead of lifetime totals?** A switch that has been running for two years will have huge lifetime error counts that don't tell you anything about *current* problems. The delta (errors since the last poll) tells you whether something is wrong **right now**.

### 5.5 Bandwidth chart

<!-- SCREENSHOT: interface-detail-bandwidth-chart -- the bandwidth chart for an active interface, showing both In (cyan) and Out (purple) lines over a 30-day period with realistic peaks and valleys -->

Below the stat cards is a **bandwidth time-series chart** showing inbound and outbound traffic over the selected period. Each data point is one polling event — if you poll every 4 hours and you're looking at a 30-day window, you'll see roughly 180 points per series.

The chart uses two colors:

- **Cyan** = inbound traffic (`In`)
- **Purple** = outbound traffic (`Out`)

Hover over any point to see the exact rate at that moment in human-friendly units. The Y-axis automatically scales to the appropriate unit (Kbps, Mbps, Gbps) based on the data — you'll never see "5,242,880 Kbps" instead of "5.0 Gbps."

If the interface has no bandwidth history yet (recently added, never polled, etc.), the chart area shows a placeholder message instead.

### 5.6 Error chart

<!-- SCREENSHOT: interface-detail-error-chart -- the error chart for an interface with input/output errors, showing red and orange bars over time -->

If — and only if — the interface has reported any errors at any point in the selected period, an **Error chart** appears below the bandwidth chart. This is a bar chart showing the number of new errors per polling interval (the same delta number you see in the stat cards, plotted over time).

The bars use two colors:

- **Red** = inbound errors
- **Orange** = outbound errors

The chart is hidden entirely when there are no errors — a clean interface has no error chart, which is by design.

> **Use case:** If you suspect a flapping cable or intermittent fiber issue, this chart is the first place to look. Sustained low-level errors look very different from periodic spikes, and the time series tells you exactly when each spike happened.

### 5.7 Details grid

<!-- SCREENSHOT: interface-detail-details-grid -- the Details grid at the bottom of the page showing all the key/value pairs (Name, Description, Alias, Speed, Duplex, VLAN, Port Mode, etc.) -->

At the bottom of the page is a **Details** grid showing the static metadata for the interface in a clean two-column layout:

- **Name** — full interface name as reported by the switch (e.g., `GigabitEthernet1/0/24`).
- **Description** — the value of `ifDescr` from SNMP. On Cisco equipment this is usually the same as the interface name.
- **Alias** — the value of `ifAlias` — the description set on the switch via the `description` command. This is the human-readable label like `LL-013 Printer` or `HSHSL-LL-AP07`.
- **Speed** — configured speed in Mbps.
- **Duplex** — `Full` or `Half` (highlighted in yellow if half).
- **VLAN** — access VLAN ID.
- **Port Mode** — `access`, `trunk`, or other.

The Details grid is meant to be a one-stop reference for the interface's configuration without having to log into the switch.

### 5.8 Tying it all together

The Interface Detail page is your deep-dive view. The most common workflow is:

1. **Spot something on the dashboard** — a port shows up in the Top Errors widget or the Top Bandwidth widget.
2. **Click into the interface** — opens the Interface Detail page.
3. **Look at the bandwidth and error charts** — does this look like a sustained problem or a one-time spike?
4. **Check the duplex badge** — is this port half-duplex? If so, the errors are probably explained.
5. **If you need to investigate the switch as a whole**, click the switch name in the header to jump back to the Switch Detail page.

The page is intentionally read-only. There's no "fix this" button — Port-Sight does not push configuration to switches. If you decide a port needs attention, you'll do that through your normal switch management workflow (CLI, SDN controller, network management platform, etc.).

---

## Chapter 6a — Built-in Reports

The Switches page that you saw in Chapter 4 is one report among many. The sidebar has two more groups of built-in reports — **Inventory** and **Capacity Planning** — and each one slices the same underlying poll data through a different lens. None of them require any setup. As soon as Port-Sight has polled your switches, every report in this chapter has data to show you.

This chapter walks through each built-in report, what question it answers, and how to read it. The next chapter (6b) covers the two reports that work differently — **Port Search** and the **Report Builder** — because those let you ask your own questions instead of choosing from a fixed set.

### 6.1 Inventory vs. Capacity Planning

The two report groups in the sidebar are organized around what you're trying to learn:

- **Inventory** answers *what hardware do I have?* — the model mix across the fleet, what firmware versions are running, what serial numbers and asset tags belong to which chassis, and what VLANs are configured where.
- **Capacity Planning** answers *how am I using what I have, and what should I buy or reclaim?* — utilization trends, recommended switch sizes for each location, projected savings, and a fleet-wide list of unused ports ready to be cleaned up.

Both groups read from the same poll database, so the numbers always agree with what you see on the Switches page and the Switch Detail page. You will never see Fleet Overview report a 48-port chassis while the Switch Detail page reports the same chassis as having 24 ports — the report just groups and aggregates the same source data differently.

> **Tip:** Almost every report in this chapter has a **Label filter** at the top. If you have site tags configured (covered in Chapter 7), you can use this dropdown to scope any report to one site, one building, or one switch group without changing pages. The label filter is local to the page you're looking at — it does not persist when you navigate elsewhere.

### 6.2 Fleet Overview

<!-- SCREENSHOT: report-fleet-overview -- the Fleet Overview page showing the model rollup table with progress bars in the % of Fleet column and EoL badges -->

**Sidebar:** Inventory → Fleet Overview

Fleet Overview is the easiest way to answer *what is my fleet actually made of?* It groups every chassis you manage by model number and shows how many of each you have, what percentage of the fleet they represent, and whether the model is approaching or past its end-of-life date.

Each row in the table is one **model** (like `WS-C3850-48U` or `C9300-48U-E`), not one switch. A row's **Units** column counts physical chassis, not management points — so a 5-member 9300 stack contributes 5 units to its model row, not 1. This is the right number for hardware accounting and refresh planning, because each chassis is a separate physical asset with its own serial number and its own EoL date.

The columns are:

- **Model** — the exact model string reported by SNMP from each chassis.
- **Family** — Port-Sight's best guess at the platform family (`Catalyst 9300`, `Catalyst 3850`, `Catalyst 2960-X`, etc.). Family detection is rule-based and runs against the model number.
- **Units** — number of physical chassis matching this model.
- **% of Fleet** — that count expressed as a share of the total chassis count, with a horizontal progress bar.
- **EoL Date** — the manufacturer's announced end-of-life date for the model, if Port-Sight has one on file. EoL data is maintained on the Equipment EoL admin page.
- **EoL Status** — `EoL` (red) if the date is already in the past, `EoL Soon` (yellow) if it's within 365 days, blank otherwise.

A **totals footer row** at the bottom shows the unit total for whatever rows are currently visible. When you have a search active, the footer also shows what fraction of the whole fleet your filtered subset represents — useful for sanity checks like "how much of my fleet is the 3850 family?"

**Click any row** to open a slide-in drawer on the right. The drawer lists every individual chassis matching that model, with switch name, IP address, and location, plus a `Copy all` button that puts the names and IPs on your clipboard as tab-separated text. This is the fastest way to get a "give me every 3850-48U I'm managing" list for refresh quoting or upgrade planning. Each switch name in the drawer is a link to that switch's Detail page.

**Search** lets you filter by either the model number or the family name. Regex is supported but the search is forgiving — invalid regex falls back to substring matching automatically.

**Export CSV** dumps the currently filtered table to a CSV file, including the EoL columns, suitable for sharing with your purchasing team or for pasting into a refresh budget spreadsheet.

> **Use case:** "How many of my switches are end-of-life or going EoL within a year?" Sort by **EoL Date** ascending and look for red and yellow badges at the top. Click each affected model to get the chassis list, copy the names, and you have your refresh shortlist.

### 6.3 Firmware Versions

<!-- SCREENSHOT: report-firmware-versions -- the Firmware Versions page grouped by model, with a gold star next to one version per model and yellow Mismatch warnings on rows with multiple versions -->

**Sidebar:** Inventory → Firmware

Firmware Versions exists to answer one specific question: *are all my switches of a given model running the same code?* Inconsistent firmware versions across identical hardware are one of the most common drivers of unexpected behavior in a fleet, and they're surprisingly easy to miss when you only look at one switch at a time.

The page groups rows **by model**, then within each model lists each distinct firmware version that's actually deployed. For each version row you see:

- The **firmware version string** (the value of `cisco-images.tarball` / IOS version that the switch reports).
- The **count** of switches running it.
- That count expressed as a **percentage of the model total**, with a small bar.
- A **gold star** (★) on the version you've designated as the "golden image" for that model, if any.

Models that have **more than one version deployed** are flagged with a yellow `mismatch` indicator, and the page header shows a running count: *N models with version mismatch* in yellow text. Models running a single uniform version are silent — they're considered healthy and need no action.

**Stacked switches** are deduplicated. A 5-member stack running the same IOS image on every member shows up as one switch on this page, not five. This is intentional — for firmware compliance you care about the management point, not each chassis.

#### Setting a golden image

The gold star is a per-user marker stored in your browser's local storage. To designate a golden image:

1. Find the model you care about.
2. Click the **outline star** (☆) next to the version you want to mark as standard.
3. The star fills in (★) and that version is now your golden image for that model.

You can only have one gold star per model. Clicking the star a second time clears it. The marker is purely visual — it doesn't push any configuration anywhere — but it makes mismatches much easier to scan for. With golden images set, a healthy model row says "100% on gold" and a problem row says "60% on gold, 40% on a different version" without any extra effort.

#### Filters and actions

- **Mismatches only** checkbox — hides every model that's running a single uniform version, leaving only the ones that need attention. This is the right filter for "what do I need to fix?"
- **Search** — matches model, family, or firmware string.
- **Label filter** — scope to a site or building.
- **Export CSV** — emits one row per (model, version) combination with counts and percentages. Useful for change-management documentation.

**Click any version row** to open a drawer showing every switch running that exact version, with a `Copy all` button. This is the fastest way to build the target list for a "upgrade these 12 switches to 17.9.5" change ticket.

> **Use case:** Right after a maintenance window, open this page with **Mismatches only** checked. If the count says zero mismatches, the upgrade is done. If there are still mismatch rows, click each one, see which specific switches still need upgrading, and you have your follow-up list.

### 6.4 Hardware Assets

<!-- SCREENSHOT: report-hardware-assets -- the Hardware Assets page showing the wide flat table with switch name, IP, location, model, serial(s), asset tag(s), firmware, EoL badge, stack indicator, and last polled column -->

**Sidebar:** Inventory → Hardware Assets

Hardware Assets is the inventory view that asset and finance teams usually want first. Where Fleet Overview groups by model and Firmware Versions groups by version, Hardware Assets is **one row per managed switch** with everything an auditor might ask about laid out in a wide flat table:

- **Switch Name** — links to the Switch Detail page.
- **IP Address** — the management IP.
- **Location** — what you set inside Port-Sight on the Switch Management page.
- **Model** — the chassis model (or, for stacks, the model of the active member).
- **Serial(s)** — every chassis serial number associated with the switch, slash-separated. For a 3-member stack you'll see three serials here.
- **Asset Tag(s)** — every distinct asset tag from your asset registry that maps to one of the chassis serials. Stack members can each have their own asset tag, and they all show up in this column.
- **Firmware** — IOS / firmware version string.
- **EoL** — `EoL` or `EoL Soon` badge if the chassis model is past or near its end-of-life date.
- **Stack** — for stacked switches, a small `N-member stack` button. Hover or click it to pop up a tooltip showing every member with its model and serial number, plus its service tag on Dell stacks (the identifier Dell support asks for).
- **Last Polled** — when SNMP last successfully read this switch.

**Sorting** — every column header except *Serial(s)* and *Stack* is sortable. Click once for ascending, again for descending. The default sort is by switch name.

#### Component-level search

The search box does more than match switch attributes. If your search string also matches a **physical component** inside any switch — a power supply serial, a network module model, a stack member's serial or Dell service tag — that component is shown inline under the matching switch's name in small monospace text. This lets you answer questions like "which switch has power supply serial PWR-XYZ123?" without having to open every switch detail page.

When component search is active, the **Export CSV** button changes its behavior: it emits one row per matched component (with the parent switch's name and IP) instead of one row per switch. This is exactly what you want for a "find the parent of this serial" lookup. With no search active, the CSV is one row per switch, with stack member info packed into a single column.

#### Stack tooltip

For stacked switches, the **N-member stack** button in the Stack column expands a small inline table showing each member's position, model, and serial, with a Service tag column on Dell stacks. Use it as a quick visual way to confirm which physical chassis you're talking about when planning a swap. If you need a richer view of every component on a switch (power supplies, fans, line cards, network modules, transceivers), use the *Hardware* tab on the Switch Detail page instead — that page lists every entity the switch reports through Entity-MIB, with a Service tag column on the Chassis section for Dell stacks.

> **Use case:** Auditor asks "show me every chassis with serial number, asset tag, and current firmware." Apply your label filter to scope to the right site, hit **Export CSV**, send the file. Done.

#### Emergency Location (E911) tab **`Admin only`**

<!-- SCREENSHOT: 17-e911 -- the Emergency Location (E911) tab: one row per switch with MAC address, description and location, the with-MAC / missing-MAC count and the Export CSV button -->

Emergency-call routing services (Microsoft Teams, Cisco Emergency Responder, any E911 Location Information Service) need to know *where* a phone is. They do that by mapping the network switch a phone is plugged into to a physical location. Port-Sight already knows every switch's base MAC address (collected during the hardware poll) and the location you've recorded for it, so this tab produces exactly the table those services import: one row per switch with **MAC address, Description, Location**.

**Using it.**

1. Make sure each switch has a Location set (Switch Management → edit switch). Switches without a location still appear, with the Location column empty.
2. Open the E911 tab. The header shows how many switches have a MAC and how many are missing one (a switch gets its MAC on its first hardware poll; run **Poll Hardware** on a switch if it's missing).
3. Use the search box to check a switch, then **Export CSV**. The file has three columns — MAC, Description, Location — in the format Teams and most LIS products accept directly.

**Keeping it current.** After you export, Port-Sight remembers what you exported. When later hardware polls change the data — a new switch, a replaced chassis with a new base MAC, a changed location — a banner appears on the tab: *"N changes since your last E911 export."* Review and **Export CSV** again; the export itself records the new baseline and clears the banner. Nothing is emailed or pushed automatically; the export is always a deliberate admin action.

The MAC exported is the switch's **base (chassis) MAC**, not a per-port MAC. A stack reports one MAC (the active member's); if the stack master changes, the next hardware poll updates it and the banner flags the change.

### 6.5 VLANs

<!-- SCREENSHOT: report-vlans -- the VLANs page with the site selector pills at the top, the VLAN list showing one or more conflict rows expanded, and the VLAN Name Mismatches panel below -->

**Sidebar:** Inventory → VLAN Report

The VLANs page answers two related questions:

1. *Which switches have VLAN N configured, and how many ports are using it?*
2. *Are all my switches in a given site spelling that VLAN's name the same way?*

The second question matters because Cisco lets you configure the same VLAN ID with a different name on different switches, and over time naming drift creeps in. `VLAN 100` might be `VOICE` on one switch, `voice-vlan` on another, and `VOIP` on a third. The traffic still flows, but the inconsistency makes auditing painful and is sometimes a symptom of misconfiguration.

#### Site selector pills

At the top of the page is a row of pills — `All Sites` plus one pill per site tag you've configured. Pick a site to scope every section of the page to switches in that site. Selecting a specific site (not `All Sites`) is what unlocks the canonical name and mismatch features described below — those features are explicitly per-site, because the "right name" for a VLAN is usually a site-by-site convention rather than a global one.

#### The VLAN list

Below the site pills, the main panel lists every VLAN ID seen in the selected scope, with its name and total port count. Columns:

- **VLAN #** — the VLAN ID, in cyan monospace.
- **Name** — the VLAN name. If different switches use different names for the same VLAN, you see one of them here plus an amber `⚠ N names` badge.
- **Ports** — total ports across all switches that have this VLAN.
- **Star column** (per-site only) — for marking the canonical name (see below).

**Click any VLAN row** to see the list of switches that have that VLAN configured, in a panel below the table. Click again to close.

When a VLAN has multiple names within the selected site, the row is highlighted in amber and the `⚠ N names` badge is clickable. Clicking it expands sub-rows showing each name variant, how many ports use that name, and how many switches have that variant. Each variant row is also clickable and shows just the switches using that specific name.

The **Conflicts only** toggle (visible when there's at least one conflict) collapses everything except the VLAN IDs with name disagreements. This is the right view when you're trying to clean up name drift across a site.

#### Canonical names and mismatch detection

Once you have a site selected, you can declare a **canonical name** for each VLAN — the official spelling for that site. Click the outline star (☆) next to a VLAN row to set the current name as canonical. The star fills in (★) and Port-Sight remembers the choice in the database (this is shared across users, unlike the Firmware page's gold star).

For VLANs that have a name conflict, you can't star the parent row directly because there's no single name to canonize. Instead, expand the variant sub-rows and star the variant whose spelling you want to make official.

As soon as any VLAN in the site has a canonical name set, a **VLAN Name Mismatches** panel appears below the main list. It shows a row for every switch whose actual name for a canonized VLAN differs from the canonical name, with columns:

- **VLAN** — the VLAN ID.
- **Current Name** — what the switch is actually using (in amber).
- **Should Be** — the canonical name for the site (in green).
- **Switch / IP / Location** — where to fix it.

This panel has its own search, sort, **Export CSV**, and **Print** buttons. Use **Print** to generate a printable change-ticket attachment listing exactly which switches need their VLAN names corrected.

**Create Dashboard Report** (top right of the VLAN list when a site is selected) creates a saved report in the Report Builder that filters to switches with any VLAN name mismatch in this site, then favorites it so it pins to your dashboard. After clicking, the button turns into a green confirmation. This is the easiest way to keep an eye on VLAN drift over time without having to open this page every day.

> **Use case:** You're consolidating two networks after a building renovation. Pick the new combined site from the pills, scan the VLAN list for amber conflict badges, expand each one, decide which spelling is the keeper, star it, then use the Mismatches panel to drive a clean-up ticket per affected switch.

### 6.6 Capacity Planner

<!-- SCREENSHOT: report-capacity-planner -- the Capacity Planner table showing per-switch utilization, recommended switch size, port and switch deltas, and projected savings, with a totals footer row -->

**Sidebar:** Capacity Planning → Capacity Planner

The Capacity Planner is the most opinionated report in Port-Sight. Instead of just showing you raw counts, it does the math for *whether each switch is the right size for its current load*, what size it should be, and what you'd save (or spend) if you swapped it. It's designed to drive refresh and consolidation conversations with finance.

The math is built around two assumptions you control at the top of the page:

- **Days threshold** — same idea as the Switches page. A port that has been "active" within the last N days counts as used. Anything older than that counts as available capacity, which the planner is willing to reclaim. The dropdown supports the standard windows (30 / 60 / 90 / 120 / 180 / 240 / All Time) plus a Custom option.
- **Growth %** and **Switch cost** — set globally on the App Settings admin page. The growth percentage adds headroom on top of current usage before the planner picks a recommended size, and the switch cost is what each "saved switch" is worth in dollars. Both are shown in the page subtitle so you know what the current numbers are based on.

For each managed switch, the planner computes:

- **Total** — current physical port count (total ports on the chassis or stack).
- **Used** — ports that have been active within the threshold window.
- **% Used** — utilization. Color-coded: red over 80%, yellow over 60%, green below.
- **Overhead** and **OH %** — unused capacity in absolute and percentage terms. Color-coded the opposite way: green for healthy headroom, red when there's almost none.
- **Rec. Size** — the smallest standard switch size (24 / 48 / 96 / 144 / 192 / 240 / 288) that fits the current Used count plus the configured growth percentage. So if a switch has 30 used ports and growth is 20%, the target is 36 ports, and the recommended size is the next standard that fits — 48.
- **Port +/-** — how many ports the switch has beyond the recommended size (positive = excess, can be removed; negative = under-sized, need to add).
- **Switch +/-** — same thing expressed in 48-port chassis units (positive = chassis you could remove, negative = chassis you'd need to add).
- **Est. Savings** — `Switch +/-` × the per-switch cost from App Settings, when positive.
- **Future OH** and **Future OH %** — what the headroom would look like if the recommended size were deployed, so you can sanity-check the recommendation has enough room to breathe.

The **Last Reload** column lives between the switch name and the size columns. It's the same field you saw on the Switches page, in the same color scheme — green if the chassis was reloaded inside the threshold window, red if it's been longer than the threshold. The reload age matters here because if a switch was reloaded yesterday and the threshold is 90 days, the "Used" count is going to look artificially low for a while as ports re-learn activity.

#### Selecting rows for the totals

Every row has a checkbox on the left, and the totals footer at the bottom of the table shows the sum across **only the selected rows**. By default, every row in the current filter is selected, so the footer shows the fleet-wide totals. Uncheck rows you want to exclude from a "what would we save?" calculation — for example, you might exclude switches that just rebooted, or switches that are deliberately oversized for future tenants.

The footer shows:

- **Total Ports / Used / Avg % Used** across the selected rows.
- **Port reduction** and **Switch reduction** — the cumulative excess across the selected rows, in green when there's something to reclaim.
- **Est. Savings** — the dollar total of the reduction, in green.

#### Filters

- **Search** — matches switch name or model.
- **Label filter** — scope to a site or building.
- **Days threshold** — same dropdown as everywhere else.

#### Exports

- **Export CSV** — emits one row per **selected** switch, with every column from the table.
- **Export PDF** — generates a formatted PDF of the same selected rows, with the threshold, growth percentage, and switch cost printed in the header. This is the export to send to finance — it's designed to be readable on its own without you having to explain the columns.

> **Use case:** "Can I make a financial case for consolidating Building C?" Apply the Building C label filter, set the threshold to 180 days (so you're not over-counting recent rebuilds), look at the totals footer, and the answer is right there in dollars. Export the PDF, attach it to the ticket.

> **Heads-up:** A handful of legacy switches still report "model" in a way that confuses the planner — usually older or unusual hardware. If you see a recommended size that obviously makes no sense for a particular row, that switch is a good candidate to exclude with the checkbox before exporting.

### 6.7 Reclaim Report

<!-- SCREENSHOT: report-reclaim -- the Reclaim Report showing the left switch selector panel with checkboxes and per-switch port counts, and the right results panel listing reclaimable interfaces grouped by switch -->

**Sidebar:** Capacity Planning → Reclaim Report

If the Capacity Planner answers *"how many switches do I have too many of?"*, the Reclaim Report answers the much more practical *"give me the actual list of ports I can clean up right now."* It is the operational counterpart to the planner — what you take into a maintenance window and start unconfiguring.

The page has a fixed two-pane layout:

- **Left pane** — switch selector with checkboxes, search, label filter, and per-switch port counts.
- **Right pane** — the results, grouped by switch, with one row per reclaimable interface.

#### Top controls

- **Threshold** — the inactivity window. Same dropdown as everywhere else (30 / 60 / 90 / 120 / 180 / 240 / All Time). After changing the threshold, click **Apply** — the report doesn't auto-refresh on threshold change because pulling unused interfaces fleet-wide is more expensive than the other reports.
- **Include uplinks** — by default, ports tagged as uplinks are excluded from the reclaim list (you almost never want to "reclaim" an uplink). Check this box to include them.
- **Include excluded** — by default, ports tagged with the built-in `exclude` tag are also hidden. Check this box to include them.
- **Export CSV** and **Print / PDF** — appear once the report has been generated.

#### Switch selector (left pane)

Every active switch in your fleet shows up in the left pane, with a checkbox and a small port count on the right. The port count is the number of ports on that switch that meet the current reclaim criteria (inactive past the threshold, not an uplink, not excluded). Switches with zero reclaimable ports are dimmed but still visible — useful as a quick "this switch is fully utilized, no action needed" signal.

By default, the report selects every switch that has at least one reclaimable port. You can:

- **Search** by name, IP, location, or model.
- **Filter by label** to scope to a site.
- Click any individual checkbox to add or remove a switch from the report.
- Use **Select all** / **Deselect all** to flip every switch currently visible in the left pane.

The header shows `selected / total` for the currently visible (filtered) switches.

#### Results (right pane)

Each selected switch becomes its own card in the right pane, with the switch name (linked to the Detail page), its IP, its location, and a port count badge in orange. Below the header is a table with one row per reclaimable interface:

- **Interface** — the interface name (e.g., `GigabitEthernet1/0/24`).
- **VLAN** — the access VLAN ID, with the VLAN name as a hover tooltip.
- **Description** — the value of `ifAlias` (the description configured on the switch).
- **Notes** — any free-form notes you've added to the interface from the Switch Detail page.
- **Mode** — `access` (teal pill) or `trunk` (purple pill).
- **Last Active** — how long it has been since the port was last used. `45d`, `120d`, or `Never`. This column is in red because by definition it's larger than your threshold.

Within each switch, rows are sorted by **age first** (oldest unused on top) then by interface name. The oldest, most-clearly-stale ports are always at the top of each card.

A counter at the top of the right pane shows the totals: `N reclaimable ports across M switches`, summed across whatever you currently have selected.

#### Exports

- **Export CSV** — one row per reclaimable interface, with switch name, IP, location, interface, VLAN, description, notes, mode, and days since active. Import this into your ticketing system or hand it to whoever is doing the actual unconfigure work.
- **Print / PDF** — generates a printable report grouped by switch, suitable for taking into a change-control review or attaching to a ticket. Each switch starts on its own block with the interface table beneath it.

> **Use case:** You have a quarterly "free up unused ports" maintenance window. Pick 180 days as the threshold (conservative — three months of nobody plugging anything in), apply the label filter for the site you're working in, hit **Apply**, then **Print / PDF**. You walk into the meeting with a per-switch list of every port you're proposing to shut down and the reasoning is right there in the **Last Active** column.

> **Why not just unconfigure them automatically?** Because Port-Sight is read-only by design. It will help you build the list, but the actual `shutdown` / `no description` / `switchport access vlan 1` commands are something you run yourself, through your normal change-management flow. This is intentional — it would be very easy to write a tool that confidently shut down ports that turn out to be in active use once a month for batch jobs, and the consequences would be ugly. Port-Sight stays on the recommendation side of that line.

---

## Chapter 6b — Port Search and Report Builder

The reports in Chapter 6a are fixed views — each one asks a specific question about your fleet and gives you the answer. The two tools in this chapter work differently. **Port Search** lets you search across every interface in the fleet using multiple filter panels combined together. **Report Builder** lets you construct your own queries from condition fields, save them, schedule nightly refreshes, and pin the results to the dashboard. Between them, they cover any question the built-in reports don't already answer.

### 6.9 Port Search

<!-- SCREENSHOT: port-search -- the Port Search page showing the Quick Port Finder at top, the three filter panels (Interface Search, Tags, VLANs) in the middle, and the results table at the bottom -->

**Sidebar:** Port Search

Port Search is the investigation tool. When you need to find every trunk port in your fleet, or every port on VLAN 100, or every interface whose name matches a regex pattern — and you need to see them all in one table with live data — this is the page.

#### Quick Port Finder

At the top of the page is a standalone **Quick Port Finder** box. This is a shortcut for the most common question: *"does switch X have any available ports right now?"*

Type a switch name or IP address. After at least one character, an autocomplete dropdown shows up to 8 matching switches with name, location, and IP. Select one, and Port-Sight immediately loads that switch's interfaces and identifies which ports are available — meaning not currently in use and not tagged as uplinks or excluded. A days threshold dropdown (30 / 60 / 90 / 120 / 180 / 240) controls how long a port must be inactive to count as available.

The result is a small table showing the available ports with interface name, VLAN, description, and last active time, plus a count showing how many are free. This is the fastest way to answer a help-desk question like "I need a port in the server room — which switch has one open?"

#### The three filter panels

Below the Quick Port Finder are three independent search panels arranged side by side. Each one searches a different dimension of your interface data. When more than one panel has active filters, the results are **AND-combined** — only interfaces matching all active panels appear in the results.

**Panel 1: Interface Search (Regex)**

A free-text regex search across interface attributes. You choose which fields to search (Interface Name, Alias, Description, Switch Name, Location — all selected by default), type a regex pattern, and click Search or press Enter. The placeholder shows examples: `^Gi0/1` or `.*wifi.*`. Full regex syntax is supported.

**Panel 2: Tags**

Shows every interface tag configured in the system as a clickable badge. Click a tag to select it — Port-Sight loads all interfaces that have that tag. Click it again to deselect. Only one tag can be active at a time.

**Panel 3: VLANs**

A searchable, sortable list of every VLAN in the fleet. Search by VLAN number or name, then click the checkbox next to one or more VLANs to select them. The table shows VLAN ID, name, and port count. VLANs with naming conflicts (same ID, different names on different switches) show an amber warning icon. You can select multiple VLANs — the results will include interfaces on any of the selected VLANs.

Each panel highlights with a cyan border when it has active results, and a **Clear** button appears showing the result count.

#### Combining panels

The power of Port Search is combining panels. For example:

- Panel 1: search for `^TenGig` (all 10G interfaces)
- Panel 3: select VLAN 100

The results table shows only 10G interfaces on VLAN 100 — the intersection. The source label above the results shows exactly what's combined: `Search: "^TenGig" ∩ VLAN: 100`.

#### Results table

The results table appears as soon as any panel has active filters. It's the most detailed interface table in Port-Sight — 14 columns covering everything you'd want to know about each port:

- **Switch** — links to the Switch Detail page, with location shown below.
- **Interface** — links to the Interface Detail page.
- **Description** — the ifAlias value.
- **VLAN** — ID and name.
- **Mode** — `access` (teal) or `trunk` (purple) badge.
- **Speed** — formatted as 1G, 10G, etc. Shows `HD` in yellow for half-duplex, `FD` in gray for full-duplex, and a lightning bolt for PoE (with power in watts on hover).
- **Admin / Oper** — status: Up (green), Down (red), or dash.
- **Last Used** — timestamp of last activity.
- **Age** — time since last activity, formatted as `3d 5h 12m`. Shows "Active" in green for currently-active ports, "Never" for ports that have never been used.
- **Traffic** — inbound and outbound bandwidth in Kbps/Mbps/Gbps.
- **Errors** — inbound and outbound error deltas, in red when non-zero.
- **Tags** — inline tag badges.
- **Notes** — click to edit inline. Press Enter to save, Escape to cancel.

Above the table, additional controls let you:

- Filter the results by **label** (site tag).
- Type in a **results filter** (regex or substring) to narrow what's shown.
- Toggle **Uplinks**, **Excluded**, and **Admin-down** visibility checkboxes.
- Click the **Up** or **Down** count buttons to filter to only up or only down ports.
- **Export CSV** — downloads the current results.

Every column is sortable. Interface names use natural sort order (`Gi0/1` before `Gi0/10`).

> **Use case:** A security team asks "show me every trunk port in Building A." Apply the Building A label filter, go to Panel 1 and leave it blank, go to the results and use the results filter to search for "trunk" in the Mode column — or just use Panel 1 to regex-search for the port and combine with Panel 3 for the VLAN. Export CSV and send the list.

### 6.10 Report Builder

<!-- SCREENSHOT: report-builder -- the Report Builder page showing the Canned Reports tab with the card grid and the Saved Reports table below -->

**Sidebar:** Report Builder

Report Builder is the most flexible reporting tool in Port-Sight. It has two tabs:

- **Canned Reports** — pre-built one-click queries for common questions, plus a table of your saved reports.
- **Custom Query** — a full query builder where you pick fields, operators, and values to construct your own report from scratch.

#### Canned Reports tab

The top of this tab shows a grid of report cards, each representing a common query:

| Report | What it finds | Mode |
|---|---|---|
| Past EoL Switches | Switches past their end-of-life date | per switch |
| Near-EoL Switches | Switches with EoL within the next year | per switch |
| Active PoE Ports | Ports currently delivering PoE power | per interface |
| Long Unused Downlinks | Non-uplink ports with no activity for 180+ days | per interface |
| All Trunk Ports | Interfaces configured as 802.1Q trunks | per interface |
| Down Ports (Admin Up) | Ports that are admin-up but operationally down | per interface |
| Ports with Errors | Interfaces with input or output errors on last poll | per interface |
| Failed to Poll | Switches whose last poll failed or never polled | per switch |

Click **Run** on any card and the conditions are loaded into the Custom Query tab, the query executes, and you see the results immediately. From there you can refine the conditions, change the view mode, or save the report.

#### Saved Reports

Below the canned report cards is the **Saved Reports** table. Every report you save appears here with:

- **Star** (★) — click to favorite/unfavorite. Favorited reports are pinned to the Dashboard as watched report cards.
- **Critical flag** (⚠) — click to mark/unmark as critical. Critical reports show in red on the Dashboard.
- **Name** — hover to reveal a rename button (pencil icon). Click to rename inline.
- **Created By** — who saved it.
- **Last Run** — when the report was last executed (manually or by the nightly scheduler).
- **Last Count** — the result count from the last run. This is the number that appears on the Dashboard card.
- **Mode** — per interface or per switch.
- **Actions** — Run (executes the report), Edit (opens in Custom Query with the saved conditions), Delete.

Saved reports refresh automatically every night via the built-in scheduler. The nightly refresh updates `Last Run` and `Last Count` for every saved report, so your dashboard cards always show current numbers without you having to manually re-run anything.

#### Custom Query tab

<!-- SCREENSHOT: report-builder-custom -- the Custom Query tab showing condition rows with field/operator/value dropdowns, the Run button, and results below in a sortable table -->

This is the query builder. You construct a report by adding one or more **conditions**, each with three parts:

1. **Field** — what to filter on. Fields are grouped:
   - *Switch:* Switch Name, Location, Model, Firmware Version, EoL Status, Last Poll Succeeded
   - *Interface:* Interface Name, Description (alias), Description (ifDescr), Notes, Port Speed, Port Mode, VLAN ID, Duplex, PoE Delivering
   - *Status:* Admin Status, Oper Status, Days Since Last Active, Is Uplink, Is Excluded, Is Admin Down, Custom Flag
   - *Tags:* Has Interface Tag, Has Switch Label, Has Site Tag
   - *Traffic:* Total Errors, In Errors, Out Errors, In Bandwidth, Out Bandwidth

2. **Operator** — depends on the field type:
   - String fields: contains, equals, starts with, not equal
   - Number fields: equals, greater than, less than, not equal
   - Boolean fields: is true, is false
   - Status fields: is up, is down
   - Tag fields: has (specific tag name)

3. **Value** — the target value. For tags and status fields, a dropdown shows the available options. For text and number fields, you type the value.

Click **+ Add condition** to add more rows. All conditions are AND-combined — every condition must be true for a row to appear.

A **query mode** toggle at the top switches between:
- **Port query** — searches across individual interfaces. All field groups are available. Results show one row per interface.
- **Switch query** — searches across switches only. Only switch-level fields are available. Results show one row per switch.

Click **Run** to execute. Results appear in a sortable table below. From the results you can:

- **Search/filter** the result set with a text box.
- Toggle **quick filters** for Oper status (up/down), Admin status (up/down), VLAN, and visibility of uplinks/excluded/admin-down ports.
- Switch the **result view** between interface view and switch view (switch view deduplicates to one row per switch with a port count).
- **Export CSV** — downloads the filtered results.

#### Saving a report

After running a query, click **Save Report** to name and save it. The report's conditions, query mode, and view mode are all persisted. Once saved, it appears in the Saved Reports table and can be:

- **Favorited** — pins it to the Dashboard as a watched report card showing the last count.
- **Marked critical** — shows the Dashboard card in red instead of cyan.
- **Edited** — reopens the conditions in the Custom Query tab for modification.
- **Renamed** — inline rename from the saved reports table.
- **Deleted** — permanently removes the saved report.

#### Dashboard integration

Favorited and critical saved reports appear as cards in the **Watched Reports** section of the Dashboard. Each card shows the report name and the `Last Count` from the most recent nightly refresh. Clicking a card opens the Report Builder, loads the saved conditions, runs the query, and shows the results.

This is the workflow for ongoing monitoring: save a report for "Ports with errors on Building A switches," favorite it, and every morning the Dashboard tells you the current count without you having to open the Report Builder at all.

> **Use case:** You want to track how many switches are running non-standard firmware. Create a Custom Query in switch mode: Field = "Firmware Version", Operator = "not equal", Value = "17.9.5" (your standard). Run it, save as "Non-Standard Firmware," favorite it. The Dashboard now shows the count every day. When you do an upgrade window, the number goes down and you can see the progress.

---

## Chapter 7 — Tags, Labels, and Tag Rules

Tags are Port-Sight's way of organizing and categorizing your fleet beyond what SNMP data provides on its own. If you've been reading this guide front to back, you've already seen tags in action — the Label Filter dropdown on report pages, the "uplink" and "exclude" badges on interfaces, the site pills on the VLANs page. This chapter explains the full system: what tags are, how they differ from labels and site tags, how tag rules automate assignments, and how all of it connects to the rest of the application.

> **Admin only:** Creating, editing, and deleting tags and tag rules requires admin access. Non-admin users can see tags on interfaces and switches, use the Label Filter on report pages, and filter by site tags, but they cannot modify the tag configuration.

### 7.1 Understanding tags, labels, and site tags

Port-Sight has two scopes of tags, and one special category:

- **Interface tags** — attached to individual ports. Examples: `uplink`, `exclude`, `admin-down`, or custom tags like `printer`, `AP`, `security-camera`. These control how Port-Sight counts and categorizes ports in reports.
- **Switch labels** — attached to switches. Examples: `Building-A`, `Core`, `IDF-2`. These are used for grouping and filtering switches across report pages via the Label Filter dropdown.
- **Site tags** — a special category of switch label. When you create a switch label and set its category to "Site," it becomes a site tag. Site tags get extra powers: they appear as filter pills on the VLANs page, they can scope tag rules to specific sites, and they're shown in bold in the Label Filter dropdown to distinguish them from regular labels.

All three are created and managed from the same **Tags** admin page. The distinction between them is set at creation time by choosing the **scope** (interface or switch) and optionally the **category** (site).

#### Reserved tags

Port-Sight ships with three reserved interface tags that have special meaning in the system:

- **uplink** — ports tagged as uplinks are excluded from unused-port counts and hidden by default on the Switches page and Reclaim Report (unless you check the "Uplinks" toggle).
- **exclude** — ports tagged as excluded are hidden from all reports by default. Use this for management ports, stack links, or any interface you never want to see in reports.
- **admin-down** — ports that are administratively shut down. Controlled by the "Admin-down" toggle on report pages.

Reserved tags cannot be renamed, deleted, or have their scope changed. They can be styled (color, border) like any other tag, and they can be assigned manually or via tag rules.

### 7.2 The Tags admin page

<!-- SCREENSHOT: admin-tags -- the Tags admin page showing the tag table with color swatches, name, scope, category, assignment count, and edit/delete/members buttons -->

**Sidebar:** Admin → Tags

The Tags page shows every tag in the system in a flat table. Three tabs at the top let you filter by scope: **All**, **Switch**, **Interface**. Each row shows:

- A **color swatch** previewing the tag badge.
- The **tag name**.
- The **scope** (Interface or Switch).
- The **category** (Site, or blank for regular tags).
- The **assignment count** — how many switches or interfaces currently have this tag.
- **Actions**: Edit, Delete (disabled for reserved tags), and a Members button to manage assignments.

#### Creating a tag

Click **+ New Tag** to open the creation modal. The fields are:

- **Name** — the tag identifier. Keep it short and descriptive.
- **Scope** — Interface or Switch. This is permanent — you cannot change it after creation.
- **Category** — only available for switch-scope tags. Set to "Site" to make it a site tag, or leave blank for a regular label.
- **Fill Color** — the background color of the badge. A color picker with an opacity slider lets you choose any color.
- **Text Color** — Auto (calculated for contrast), Light, or Dark.
- **Border Color** — defaults to matching the fill color. Uncheck "Same as fill" to pick a separate border color.

A **live preview** at the bottom of the modal shows exactly how the badge will look as you adjust colors.

#### Editing a tag

Click **Edit** to reopen the modal. You can change everything except the scope and (for reserved tags) the name. Color changes take effect immediately across the entire application — every badge, every filter pill, every report page showing that tag updates to the new colors.

#### Quick assignment from Switch Management

You do not have to open a tag to assign it. On **Admin → Network → Switch Management** every row has a **+** button in its Tags column that opens a tag picker (search, tick, done), and with several switches selected the **Edit selected** button (v2.15.21) opens one form for everything that makes sense to change on many switches at once: SNMP settings (version, port, community or v3 user, protocols and passwords), site, location, polling on or off, and tags to add or remove. Every field is “leave as is” until you touch it, so you can change only the credentials and nothing else; passwords go in encrypted and are never shown back. Name, IP address and asset tag are per device and stay on the row. The same selection bar offers **Poll Selected**, which is also how you test new credentials, and **Delete Selected** (type DELETE to confirm; deleting removes history — archive a switch instead if you want to keep it).

#### Managing tag members

Click the **Members** button to open the assignment modal. This works differently depending on the tag scope:

**For switch labels:**
The modal shows a checkbox table of every switch in the system. Check the box next to each switch you want to assign this label to. The table is searchable (name, IP, location, model) and sortable by column headers. If site tags exist, filter pills at the top let you scope the list to a specific site or show only unassigned switches.

Switches assigned by tag rules show as locked rows marked "Auto" — you cannot manually uncheck them. Manual assignments show as "Manual." The footer shows the total: "5 manual + 3 auto."

**For interface tags:**
The modal shows a read-only list of all interfaces currently assigned this tag, with the assignment source (Auto or Manual). You can remove manual assignments one by one, but auto-assigned tags (from tag rules) cannot be removed here — disable the rule that created them instead.

### 7.3 Tag Rules

<!-- SCREENSHOT: admin-tag-rules -- the Tag Rules page showing the rules table with name, tag, field, pattern, AND conditions, site limit, enabled toggle, and action buttons -->

**Sidebar:** Admin → Tag Rules

Tag rules let you automatically assign tags to interfaces or switches based on regex patterns and additional conditions. Instead of manually tagging every uplink port on every switch, you create a rule like "any interface whose name starts with `TenGigabitEthernet` and is a trunk → tag as uplink" and Port-Sight applies it fleet-wide.

#### How rules work

Each rule has:

1. **A target tag** — the tag to assign when the rule matches.
2. **A field to match** — depends on the tag scope:
   - Interface tags: Interface Name, ifDescr, Description (alias), VLAN, or Any Field.
   - Switch labels: Hostname, IP Address, or Model.
3. **A regex pattern** — matched against the field value. For example, `^TenGig` matches any interface name starting with "TenGig."
4. **Optional AND conditions** (up to 4) — additional criteria that must also be true. Each condition has a field, an operator, and a value. Operators are equals, not equals, and regex; the text fields (Interface Name, ifDescr, Description) also offer **is empty** and **is not empty**, which need no value — handy for "has no description" rules. For example: Admin Status = Up AND Oper Status = Down AND VLAN = 100. Available condition fields are Admin Status, Oper Status, Duplex, VLAN, Interface Name, ifDescr, Description (alias), **Port mode** (access / trunk / unknown — from the switchport configuration collected by the poll) and Has Interface Tag. Port mode is the usual way to keep a rule off uplinks: an "exclude everything on VLAN 1" rule with the condition Port mode = access will not catch the trunks to your firewalls.
5. **Optional site limit** — restrict the rule to switches in specific sites. If no sites are selected, the rule applies to all switches.
6. **Enabled toggle** — turn a rule on or off without deleting it.

When a rule matches, the tag is assigned with source "Auto." Auto-assigned tags are controlled by the rule: if you disable or delete the rule, its assignments are cleared. You can still keep a rule off one particular port — see **Keeping a rule off one port** below.

#### Creating a rule

Click **+ New Rule** to open the rule editor. As you type the regex pattern, a **live test panel** below the form shows matching results in real time (with a short debounce). Matched values appear in green, so you can verify the pattern is hitting the right targets before saving.

The live test is the most important part of the rule creation workflow. Write the pattern, watch the matches, add AND conditions to narrow them down, and only save when you're seeing exactly the results you expect.

#### Applying rules

Rules are applied in two ways:

1. **Manual** — click the **Apply Rules** button at the top of the Tag Rules page. Port-Sight runs all enabled rules and shows a feedback message: "X new assignments created." If an apply fails (a database error, say), the page shows the error instead of pretending it completed.
2. **Automatic** — rules run automatically after every polling cycle. When new interfaces are discovered or switch attributes change, the rules re-evaluate and update assignments.

#### Keeping a rule off one port

Rules are fleet-wide, and now and then one port is the exception — a phone port a "VLAN 1 → exclude" rule keeps hiding, for instance. On the switch page, hover a tag chip to see where it came from (assigned by hand, or by which rule, and when). Remove a rule-applied tag from the chip and the port is marked **kept off**: the rule will not put that tag back on that port until you clear the kept-off marker from the chip. Kept-off ports are remembered per port and per tag, so the rule keeps working everywhere else.

Because the reserved `exclude` tag hides interfaces from most pages, the switch page tells you when that is happening: **"N hidden by filters"** with a **Show all** link that clears every filter at once.

#### Example rules

| Rule name | Tag | Field | Pattern | AND conditions | Effect |
|---|---|---|---|---|---|
| 10G uplinks | uplink | Interface Name | `^TenGig` | Port Mode = trunk | Tags all 10G trunk ports as uplinks |
| AP ports | AP | Description (alias) | `(?i)ap\|access.point` | — | Tags ports with "AP" or "access point" in the description |
| Building A | Building-A | Hostname | `^SW-BldgA` | — | Labels all switches whose hostname starts with SW-BldgA |
| Empty NM slots | exclude | Interface Name | `^TenGig.*4[89]\|^TenGig.*5[0-9]` | Oper Status = Down, Admin Status = Down | Excludes phantom ports on empty network module slots |

### 7.4 The Label Filter

<!-- SCREENSHOT: label-filter -- the Label Filter as it appears on a report page, showing site tag pills in bold and regular label pills below -->

The Label Filter is the dropdown/pill bar that appears at the top of the Switches page, Fleet Overview, Firmware Versions, Hardware Assets, Port Search, Capacity Planner, and Reclaim Report. It shows all switch-scope tags as clickable pills.

- **Site tags** appear in bold to distinguish them from regular labels.
- If both site tags and regular labels exist, they're separated into labeled groups.
- Click any pill to select it. Click again to deselect.
- **Multiple pills can be selected** — the filter shows switches matching ANY of the selected tags (OR logic).
- The filter is local to the page you're on. Navigating away resets it.

The Label Filter is the primary way non-admin users interact with tags. You don't need admin access to filter — just click the pills and the page updates.

### 7.5 Where tags appear

Tags touch many parts of Port-Sight. Here's a quick reference:

| Where | What you see |
|---|---|
| **Switches page** | Label Filter pills at top; filter by site or label |
| **Switch Detail page** | Interface tags shown as colored badges in the interface table |
| **Port Search** | Panel 2 (Tags) lets you search by interface tag; Label Filter scopes results by switch label |
| **Report Builder** | "Has Interface Tag," "Has Switch Label," and "Has Site Tag" condition fields |
| **Fleet Overview / Firmware / Hardware Assets** | Label Filter for switch-level filtering |
| **VLANs page** | Site tags appear as filter pills at the top |
| **Capacity Planner / Reclaim Report** | Label Filter for switch-level filtering |
| **Dashboard** | Site tag filter in header (scopes summary cards and widgets) |

> **Tip:** If you're just getting started with tags, create site tags first. Even two or three site tags (one per building or campus) immediately make every report page more useful because you can scope any view to a single site with one click. Interface tags and tag rules can come later as you refine your workflow.

---

## Chapter 8 — Polling

> **Admin only:** Everything in this chapter requires admin access. Non-admin users can see poll results (the data that appears on every report page), but they cannot trigger polls, change schedules, or view poll history.

Polling is how Port-Sight collects data from your switches. Every number on every report page — port counts, utilization percentages, bandwidth, errors, VLANs, firmware versions — comes from SNMP polls. This chapter explains the two types of polling, how to configure schedules, how to trigger manual polls, and how to read the poll history.

### 8.1 Two types of polls

Port-Sight runs two independent polling cycles:

**Interface polling** is the primary poll. It walks every switch's interfaces via SNMP to collect operational state (admin status, oper status, speed, duplex), traffic counters (bandwidth in/out, errors in/out), VLAN assignments, port mode (access/trunk), PoE status, and the `ifLastChange` timestamp used to compute how long a port has been active or inactive. This is the poll that drives the Switches page, all capacity reports, Port Search, and the Report Builder.

**Hardware inventory polling** collects chassis-level data via Entity-MIB: physical components (power supplies, fans, line cards, network modules, supervisors), serial numbers, model numbers, and stack membership. This is the poll that drives the Hardware Assets page, Fleet Overview, and Firmware Versions. Hardware data changes rarely — you add a power supply or swap a line card once in a while — so this poll runs much less frequently than interface polling.

Both types are independent. You can run interface polls every hour and hardware polls once a month. Changing one schedule does not affect the other.

### 8.2 The Polling page

<!-- SCREENSHOT: admin-polling-schedule -- the Polling admin page showing the Schedule tab with the interface polling schedule form and the hardware inventory schedule form below it -->

**Sidebar:** Admin → Polling

The Polling page has two tabs: **Schedule** and **History**.

#### Schedule tab

The Schedule tab has two sections stacked vertically:

**Interface Polling Schedule**

At the top is a **Poll All Now** button that triggers an immediate interface poll of every active switch. Below that, a status box shows when the next scheduled poll will run and when the schedule was last saved.

The schedule form has these controls:

- **Polling Enabled** toggle — master switch. When off, no automatic polls run. Manual polls via "Poll All Now" still work.
- **Frequency** — Hourly, Daily, or Weekly.
- **Interval** — how often within the frequency. "Every 2 hours" or "Every 3 days." For hourly, the range is 1–23. For daily, 1–30. Weekly frequency doesn't have an interval — it runs once a week.
- **Day of Week** — only shown for weekly frequency. Monday through Sunday.
- **Time of Day** — hour (0–23) and minute (in 5-minute increments). For hourly frequency, this is the starting time of the cycle. For daily and weekly, this is when the poll runs.

A note below the form explains that switches are polled in **batches of 4** with a short pause between batches. This is intentional — polling 200 switches simultaneously would look like a network scan to IPS/IDS systems and could trigger alerts. The batch size is tuned to be fast enough for timely data but gentle enough to avoid security alarms.

Click **Save Schedule** to persist changes. The schedule takes effect immediately — you don't need to restart the application.

**Hardware Inventory Schedule**

Below the interface schedule is a separate form for hardware polling:

- **Poll All Hardware Now** button — triggers an immediate hardware inventory poll of every active switch.
- **Frequency** dropdown — Manual Only, Weekly, Monthly (default), or Quarterly.
- A note recommends monthly or quarterly for most environments, since hardware polls are slower than interface polls and the data they collect changes infrequently.

Click **Save Schedule** to persist. Like the interface schedule, changes take effect immediately.

#### Default schedule

A fresh Port-Sight installation starts with:
- Interface polling: **Daily at 02:00**, enabled
- Hardware polling: **Monthly**

Most environments should adjust the interface poll to hourly (every 1–4 hours) after the initial setup to get more granular bandwidth and error trending data.

### 8.3 What happens during a poll

When a poll starts — whether triggered manually or by the scheduler — a **progress banner** appears at the top of every page in Port-Sight:

<!-- SCREENSHOT: poll-banner -- the cyan progress banner showing "Polling in progress... 42 of 118 switches (36%)" with a thin progress bar -->

The banner shows:
- A spinning icon
- "Polling in progress… **X** of **Y** switches (**Z**%)"
- A thin progress bar that fills as switches complete

The banner updates every second. When the last switch finishes, the banner disappears automatically.

During a poll, all pages continue to work normally. You can browse reports, search ports, and manage switches while polling runs in the background. Data updates as each switch completes — you don't have to wait for the entire poll to finish before seeing results.

If a switch fails to poll (network timeout, SNMP credential error, switch unreachable), it's recorded as a failure in the poll history but the poll continues with the remaining switches. One bad switch does not block the rest.

### 8.4 Poll History

<!-- SCREENSHOT: admin-polling-history -- the History tab showing the poll run table with time range pills, status filter buttons, and per-switch poll results -->

The **History** tab shows a record of every poll run — one row per switch per poll cycle. This is the diagnostic view when something isn't working.

**Time range pills** at the top control how far back to look:

- **Latest** (default) — shows only the most recent poll result per switch. This is the "is everything healthy right now?" view.
- **24h / 3d / 7d / 30d** — shows all poll runs within that window.
- **Custom** — date range picker for specific windows.

**Status filter buttons** show the count of successes and failures in the current time range:

- **All** — every poll run.
- **OK (N)** in green — only successful polls. Click to filter.
- **Failed (N)** in red — only failed polls. This is the first button to click when troubleshooting.

**Search** — filter by switch name (regex supported).

The table shows one row per poll run with these columns:

- **Switch** — links to the Switch Detail page.
- **Polled At** — timestamp of the poll.
- **Status** — green checkmark for success, red X for failure.
- **Uptime** — how long the switch has been up, reported by the switch via `sysUpTime`. Shown as days and hours.
- **Interfaces Found** — how many ethernet interfaces the poll discovered on this switch.
- **Interfaces Updated** — how many interfaces had a state change since the last poll (new data was written).
- **Error** — if the poll failed, the error message. Common errors include SNMP timeout, authentication failure, and host unreachable.

Every column is sortable. Pagination controls at the bottom let you page through large result sets (50 / 100 / 250 / 500 per page).

> **Troubleshooting tip:** If a switch shows "SNMP timeout" in the error column, the most common causes are: (1) wrong SNMP credentials — re-enter them on the Switch Management page, (2) the switch's SNMP ACL doesn't include the Port-Sight server's IP, or (3) a firewall between Port-Sight and the switch is blocking UDP 161. If the error is "Authentication failure," the credentials are reaching the switch but being rejected — check the username, auth password, and priv password.

### 8.5 First poll behavior

When you add a new switch to Port-Sight, its first interface poll populates all of the interface data. If the switch has never been polled before (`last_polled_at` is null), Port-Sight also automatically triggers a **hardware inventory poll** for that switch at the end of the interface poll. This means you don't need to wait for the next scheduled hardware poll cycle — the switch's model, serial numbers, stack membership, and physical components are collected immediately.

Subsequent hardware data is collected on the hardware polling schedule you configured.

### 8.6 Polling and licensing

Polling requires a valid license (or an active trial). When the license expires:

- **Automatic polls stop.** The scheduler continues to run but skips execution.
- **Manual polls are disabled.** The "Poll All Now" and "Poll All Hardware Now" buttons are grayed out with a tooltip explaining why.
- **All existing data is preserved.** Reports, history, and dashboards continue to work — you just can't collect new data until the license is renewed.

The Dashboard shows a warning banner when your license is within 30 days of expiring, giving you time to renew before polling stops.

---

## 9. Single Sign-On with SAML **`Admin only`**

Port-Sight can let users sign in through your organization's identity provider (IdP) — Okta, Microsoft Entra ID (Azure AD), ADFS, or any SAML 2.0 provider — instead of (or alongside) local Port-Sight passwords and LDAP.

### 9.1 How SAML SSO works (the short version)

When SSO is configured, the login page shows a **"Sign in with *[your provider]*"** button. Clicking it sends the user to your IdP, the IdP confirms who they are, and the user is returned to Port-Sight already logged in. Port-Sight never sees the user's password — the IdP handles that.

A few things worth knowing:

- **You don't pre-create SSO users.** The first time someone signs in through SSO, Port-Sight creates their account automatically. They appear in **User Management** with a **SAML** badge.
- **It's browser-based.** The login information travels through the user's browser, not directly between Port-Sight and the IdP. This means **Port-Sight does not need to be reachable from the internet** — only the user's browser needs to reach both your IdP and Port-Sight. No inbound firewall rule from the IdP is required.
- **You can configure more than one provider.** Each enabled provider gets its own button. Users pick the right one; there is no password box for SSO.

### 9.2 Access modes — who gets in, and who's an admin

Each provider has an **Access Mode** that controls access:

- **Open** — anyone your IdP authenticates is allowed in as a regular user. You decide who can authenticate over in the IdP (by who you assign the app to).
- **Group** — the user must be a member of a specific group (sent by your IdP) to log in at all. Members of the access group get regular access; members of the admin group get admin. A user in neither group is denied.

Independently, there's an optional **Admin Group** field:

- **If you set an Admin Group**, that group decides admin rights, and Port-Sight re-applies it on every login. For those users, the Admin checkbox in User Management becomes read-only and shows **"Managed by SSO"** — because changing it by hand would just be overwritten at their next login.
- **If you leave the Admin Group blank**, Port-Sight never touches admin for SSO users — you grant admin by hand in User Management, like a local account.

> This is an all-or-nothing setting per provider: the Admin Group is configured on the provider, so it applies to everyone who logs in through that provider, not per individual user.

### 9.3 Setting up a provider

The setup is a two-way exchange: your IdP needs three values from Port-Sight, and Port-Sight needs three values from your IdP.

1. In Port-Sight, go to **Admin → SAML SSO → Add Provider**.
2. Fill in:
   - **Display Name** — the label on the login button (e.g. "Okta" or "Company SSO").
   - **Public Base URL** — the exact URL users type in their browser to reach Port-Sight, **including the scheme and any custom port** (e.g. `https://portsight.example.edu` or `http://portsight.example.edu:9080`). This must match reality — if your site runs on a custom port, include it.
3. You'll need the three IdP values from your provider (next sections) — **IdP Entity ID**, **IdP SSO URL**, and the **IdP X.509 Certificate** — paste them in, then **Save**.
4. **Edit** the saved provider. Port-Sight now shows three read-only values with Copy buttons — give these to your IdP:
   - **ACS URL** (some IdPs call this the *Reply URL* or *Assertion Consumer Service URL*)
   - **SP Entity ID** (sometimes the *Audience* or *Identifier*)
   - **SP Metadata URL**
5. Set the **Access Mode** and, if using Group mode, the **Access Group** / **Admin Group** values (see 9.2).
6. Leave **Required IdP signature** on **Either** (the default). Port-Sight always requires at least one valid digital signature on the SAML response — it never accepts an unsigned login — and "Either" auto-detects whether your IdP signed the *Response* or the *Assertion* and verifies that one. This is what makes Port-Sight work with almost any IdP unchanged (Okta and Entra sign the Assertion; Shibboleth signs the Response). The stricter modes — *Assertion*, *Response*, or *Both* — are available if your security policy mandates a specific one. (Note: **Either** means "Response *or* Assertion is accepted" — the flexible choice; **Both** is the *strictest* setting, requiring the IdP to sign both at once. Don't pick "Both" expecting "either works.")
7. Enable the provider, sign out, and test the "Sign in with…" button. Use a private/incognito window if you're already signed into the IdP and want to see the full prompt.

> **Scheme and port must match exactly** on both sides. If Port-Sight's Public Base URL says `http://…:9080` but the IdP has `https://…`, sign-in will fail with a "could not be verified" error, because the response was delivered to an address Port-Sight didn't expect.

### 9.4 Setting up Microsoft Entra ID (Azure AD) — step by step

Entra is the most common production choice, and it has a few specifics — especially around groups — that differ from the generic flow. The exchange is the same idea as 9.3 (Entra needs three values from Port-Sight; Port-Sight needs three from Entra), but Entra's labels and group claim need particular handling.

**A. Create the application**
1. In the **Microsoft Entra admin center** (entra.microsoft.com) → **Identity → Applications → Enterprise applications → New application → Create your own application**.
2. Name it (e.g. `Port-Sight`), choose **"Integrate any other application you don't find in the gallery (Non-gallery)"**, then **Create**.
3. Open the app → **Single sign-on** → choose **SAML**.

**B. Basic SAML Configuration** (section 1 on the SAML page) — click **Edit**:
- **Identifier (Entity ID)** = Port-Sight's **SP Entity ID** (from Port-Sight's provider Edit screen)
- **Reply URL (Assertion Consumer Service URL)** = Port-Sight's **ACS URL**
- Leave Sign on URL, Relay State, and Logout URL blank. **Save.**

**C. Attributes & Claims — the group claim** (this is the part that differs most from Okta):
1. In section 2, **Edit → Add a group claim**.
2. Choose which groups to send — **"Groups assigned to the application"** is recommended (keeps the claim small; you'll assign your Port-Sight groups to the app in step E). "Security groups" also works.
3. **Source attribute** — *this is the important one.* By default it's **Group ID**, which sends each group's **Object ID** (a GUID like `8c4f1a3e-…`), **not** the group's name. Two ways to handle it:
   - **Simplest / most reliable:** leave it as **Group ID**, and in Port-Sight set the **Access Group** / **Admin Group** values to each group's **Object ID** (copy it from Entra → Groups → your group → Overview).
   - **If you prefer readable names:** change Source attribute to **"Cloud-only group display names"** (for cloud groups) or **sAMAccountName** (for groups synced from on-prem AD); then you can use the group *name* in Port-Sight. These name sources have caveats and aren't available for every group type, so Group ID is the dependable default.
4. **Claim name** — by default Entra names the group claim `http://schemas.microsoft.com/ws/2008/06/identity/claims/groups`, but Port-Sight's **Group Attribute** field defaults to `groups`. Make them match by doing **one** of:
   - In the group-claim dialog, expand **Advanced options → "Customize the name of the group claim"** and set **Name** = `groups` (leave Namespace blank); **or**
   - Leave Entra's default and set Port-Sight's **Group Attribute** field to the full URI `http://schemas.microsoft.com/ws/2008/06/identity/claims/groups`.

**D. Get the three IdP values for Port-Sight** (sections 3 & 4):
- **Section 3 — SAML Certificates:** download **Certificate (Base64)**, open it in a text editor, and copy the entire block (including the `-----BEGIN CERTIFICATE-----` / `-----END CERTIFICATE-----` lines) → Port-Sight's **IdP X.509 Certificate**.
- **Section 4 — "Set up [app name]":**
   - **Login URL** → Port-Sight's **IdP SSO URL**
   - **Microsoft Entra Identifier** → Port-Sight's **IdP Entity ID**

**E. Assign users and groups**
- In the app → **Users and groups → Add user/group** → assign yourself, plus your `PortSight-Users` / `PortSight-Admins` groups. This is required both so people can sign in (Entra enterprise apps default to **Assignment required = Yes**) and, if you chose "Groups assigned to the application" in step C2, so those groups appear in the claim.

**F. Finish in Port-Sight**
- In **Admin → SAML SSO**, paste the IdP Entity ID, IdP SSO URL, and Base64 certificate; confirm the **Public Base URL**; set **Access Mode** and the **Access/Admin Group** values (Object IDs or names, matching your choice in step C3). **Save**, then test.

> **NameID:** Entra's default unique identifier is the user's UPN (usually their email), which Port-Sight uses as the account identity — the default is fine. Leave Port-Sight's NameID format set to "Email address."

### 9.5 Setting up Okta

- Create a custom **SAML 2.0** app integration (not a pre-built gallery app).
- Map fields: **Single sign-on URL** = Port-Sight's ACS URL; **Audience URI (SP Entity ID)** = Port-Sight's SP Entity ID. From the **Sign On** tab's setup instructions you get the **Identity Provider Single Sign-On URL** (→ IdP SSO URL), **Identity Provider Issuer** (→ IdP Entity ID), and **X.509 Certificate** (→ IdP Certificate).
- To send group membership, add a **Group Attribute Statement** named `groups` (Filter: *Starts with* `PortSight`). In recent Okta (Identity Engine 2025.12 and later) this section was **moved to the app's *Sign-On* tab** (under "Attribute Statements (SAML)" — click *Show legacy configuration* if needed). It is **no longer** on the Configure SAML / General screen, which trips a lot of people up.
- Don't forget to **assign yourself (and your users) to the app** under the Assignments tab — without assignment, login fails.

### 9.6 Setting up Shibboleth (and other proxy IdPs)

Shibboleth is common in higher-education and enterprise environments, often as a middleware/proxy in front of another identity source (e.g. Microsoft Entra). Port-Sight is the Service Provider and talks to **Shibboleth as the IdP**. The value exchange is the same as 9.3; two specifics matter:

- **Signing.** Shibboleth signs the overall **Response** by default, not the inner Assertion. Leave Port-Sight's **Required IdP signature** on **Either** (the default) and it works with no Shibboleth-side change. *(If you set a stricter mode by mistake, login fails with "The Assertion of the Response is not signed and the SP requires it" — switch it back to Either.)*
- **Attribute names arrive as OID URNs**, not friendly names. Map Port-Sight's attribute fields to the OID URNs your IdP team releases. Common ones:

  | Port-Sight field | Typical Shibboleth attribute (OID URN) | Meaning |
  |---|---|---|
  | Username attr | `urn:oid:1.3.6.1.4.1.5923.1.1.1.6` | eduPersonPrincipalName |
  | Email attr | `urn:oid:0.9.2342.19200300.100.1.3` | mail |
  | Display name attr | `urn:oid:2.16.840.1.113730.3.1.241` | displayName |
  | Group attr | the OID URN groups are released under (e.g. `isMemberOf` = `urn:oid:1.3.6.1.4.1.5923.1.5.1.1`, or a site-specific name) | group membership |

- **Group mode requires the IdP team to release a group/membership attribute** carrying your access/admin group values. Ask them for the exact attribute Name (OID URN) and the exact string values it contains, then set Port-Sight's **Group Attribute** to that OID and the **Access Group / Admin Group** values to those strings. Until groups are released, use **Access Mode = Open** so any authenticated user can sign in, and manage admin rights in User Management.

### 9.7 Troubleshooting SSO

If a login fails, the reason is recorded in **Admin → Audit Log** — look for a `saml_auth_failed` or `saml_access_denied` entry; its details include the specific reason. Common ones:

- **"could not be verified"** — usually a scheme/port mismatch between the IdP's reply URL and Port-Sight's Public Base URL, or a wrong/incomplete IdP certificate.
- **"The Assertion of the Response is not signed and the SP requires it"** (or another signature complaint) — your IdP signs a different part than the configured requirement. Set **Required IdP signature** back to **Either** (the default). Most often seen with Shibboleth, which signs the Response rather than the Assertion.
- **"not authorized for this application"** — the user authenticated but isn't in the access (or admin) group, in Group mode.
- **Authenticated but denied in Group mode, and the group value shows as empty** — the IdP isn't releasing the group attribute under the name Port-Sight expects. The `saml_access_denied` Audit Log entry lists the **attribute names actually received** — use that to find the correct attribute (often an OID URN) and set Port-Sight's **Group Attribute** to match.
- **Comes in as a regular user when they should be admin** — the admin group value in Port-Sight doesn't match what the IdP sends (e.g. you typed a group *name* but Entra is sending the group's *Object ID*).

---

## 10. Network Maps

Network Maps are hand-drawn diagrams of your network — a root map of the core with clouds that drill into buildings, closets, or datacenters, each showing only the devices and links its author chose to include. Unlike every other page in Port-Sight, a map is never auto-generated: an admin builds it once, and everyone else sees exactly what was built.

### 10.1 What a map shows

<!-- SCREENSHOT: 41-map-viewer -- a map viewer page showing switch nodes, a router, a cloud drilling to another map, and several links with half-arrow rate labels -->

A map is made of **nodes** and **links**.

- **Nodes** are switches, routers, firewalls, clouds, text/legend labels, plain icons, action icons, and NetFlow icons. A node bound to a switch in inventory shows a live **status dot**.
- **Links** connect two nodes. Every link is drawn as **two half-arrows** meeting at the midpoint — one half for each direction of traffic. Each half is colored and labeled independently, showing that direction's current rate (and, once a capacity is known, its utilization percentage). A label at the midpoint shows the link's name or capacity (e.g. `100M FIBER`).

**What the colours mean.** Every colour on a map means exactly one thing, whether it's painting a link or a drill-icon's status dot — no colour is ever reused for two different conditions:

| Colour | On a link | On a drill icon (cloud, or anything opening another map) |
|---|---|---|
| Green | Utilization below the yellow threshold (default 50%) | Every switch reachable from here polled successfully, and no link issue anywhere downstream |
| Yellow | Utilization in the yellow band (default 50–70%) | A downstream link is in the yellow band, or a switch reachable from here has never successfully polled |
| Orange | Utilization in the orange band (default 70–85%) | A downstream port-channel member is down while its aggregate is still up, or a link is in the orange band |
| Red | Utilization at or above the red threshold (default 85%) | A switch's last poll failed, a mapped link is operationally down, or a link is at/above the red threshold, anywhere downstream |
| Gray | No utilization reading yet (unbound, or no sample yet) | Nothing is bound anywhere in reach |

The three band thresholds (yellow/orange/red) are set fleet-wide by an admin — see [10.6 Map settings](#106-map-settings) — so the numbers above may differ from what your install actually uses; the legend in the map header always shows the live values.

**Status dots** mean different things depending on the node:

- On a **switch node**, the dot reflects that one switch's own last poll — green for success, red for a failed poll, gray for a switch that has never successfully polled.
- On a **cloud or drill node** (anything that opens another map), the dot is **rolled up**: it shows the worst status found anywhere in that map and everything it drills into (see the table above), so a red dot on a drill icon means a switch is failing, or a link is down or overloaded, somewhere down the chain even if nothing on the current map is red.

**Subnets behind a link.** Port-Sight works out which IP subnets sit behind each mapped link — the VLAN(s) served past that link and the subnet(s) those VLANs use — by walking the routed interfaces (SVIs) on your L3 switches and matching them to the access VLANs on the link's downstream (leaf) side. Hovering a link half that has this figured out adds a **"Subnets behind this link"** list to the tooltip, one line per subnet (e.g. `10.10.210.0/24 · VLAN 210 · via core-9606 (2 hops)`). The **via** clause names the switch whose SVI actually supplied the subnet and how far it is from the link ("own SVI" for the downstream switch's own routed interface, "1 hop" / "2 hops" for a neighboring switch's, or "via fleet" when Port-Sight found it somewhere in the fleet without a clean topological path). A `?` after an entry means more than one subnet claims the same VLAN id and Port-Sight couldn't confirm which one from host data — treat it as unconfirmed rather than authoritative. **From v2.13**, a link with at least one subnet also gets a small **Top Talkers glyph** at its midpoint (see [chapter 14](#14-top-talkers)) — click it to see who's actually using that subnet right now.

### 10.2 Opening and navigating

**Sidebar:** Monitor → Network Maps

<!-- SCREENSHOT: 40-maps-list -- the Network Maps list page showing root maps first, with drill maps indented underneath -->

The maps list shows root maps first, with the maps they drill into indented underneath. Click a map to open it. A map always opens **locked** — you're viewing it, not editing it.

Inside a map:

- **Breadcrumbs** at the top show the drill chain (Maps → Parent Map → this map), so you can always find your way back up.
- **Pan** by dragging the canvas, **zoom** with the scroll wheel or the on-screen zoom controls, and click **Fit** to re-center and re-scale the view around the nodes on the map.
- The **legend** (the four green / yellow / orange / red utilization bands, and where the rates come from) sits in the header under the buttons, off the canvas.
- **Refresh** re-fetches the map's current rates. A caption under the title reads "Sampled every N min" with the time of the last sample, so you know how current the numbers are. If you're an admin, clicking Refresh also kicks off an immediate poll of that map's links instead of waiting for the next scheduled cycle.
- **Hovering a link half** shows a tooltip with the direction, the rate (and percentage, if a capacity is set), the bound interface name, and a line telling you where the number came from — see below.

<!-- SCREENSHOT: 42-map-hover-link -- a link half being hovered, showing the tooltip with direction, rate, interface name, and the sample-vs-average source line -->

### 10.3 Where the numbers come from

Map links get their rate from one of two places:

- **A 5-minute sample.** Interfaces that are bound to a map link are polled by a dedicated link poller on a short interval (5 minutes by default; an admin can change it). This is what makes a map feel "live."
- **The 4-hour fleet average.** If no recent sample exists yet, the link falls back to the same interface-poll average used everywhere else in Port-Sight.

The hover tooltip always tells you which one you're looking at — "5-min sample, 2 min ago" versus "fleet-poll average (4 h), no recent sample." Because the rate for a given interface is computed once per poller cycle, the same physical link shows the same number no matter how many maps it appears on.

Whichever source the rate comes from, the same percentage decides the link's colour — see [10.1's colour table](#101-what-a-map-shows) for what green/yellow/orange/red mean and where the band thresholds are configured.

When a sampled link has recent history, hovering it also draws a short sparkline of the last few hours next to the tooltip. For a longer view, open the interface's own page — any map-bound interface has a **"5-minute samples (last 24h)"** chart in addition to its normal bandwidth chart.

<!-- SCREENSHOT: 53-interface-5min-samples -- the Interface Detail page's "5-minute samples (last 24h)" chart below the regular bandwidth chart -->

### 10.4 Building a map

> **Admin only:** Building and editing maps requires admin access. Anyone signed in can open and view a saved map.

<!-- SCREENSHOT: 43-map-editor -- the map editor showing the unlocked canvas, the palette on one side, and a selected link's properties panel on the other -->

Click **Edit map** to unlock it. While unlocked, nothing you do is visible to anyone else until you save.

**The palette** offers:

- **Switch (from inventory)** — place one switch, or open the multi-select picker (below) to place several at once.
- **Router**, **Firewall**, **Cloud / drill-down**, **Text / legend**, **Action icon**, **NetFlow icon** — generic node kinds.
- **Image / icon** — place a node using an uploaded image from the asset library.
- **Icon** — place a node using the built-in icon library.
- **Link tool (click A, then B)** — click one node, then another, to draw a link between them.

**Adding many switches at once.** Picking Switch (from inventory) with the multi-select picker lets you tick several switches (or **Select all N filtered**) and drop them onto the canvas in a grid in one step. If you leave **Also link them** checked, Port-Sight looks at CDP/LLDP data (and confirmed port-channel membership) and proposes links between the switches you just added — port-channels are only proposed when both ends confirm the same LAG membership. Nothing is created until you review and confirm the proposed links in the review step that follows.

<!-- SCREENSHOT: 44-map-add-switches -- the multi-select switch picker with several switches ticked and the "Also link them" checkbox visible -->
<!-- SCREENSHOT: 45-map-link-review -- the link suggestion review step listing proposed links with their CDP/LLDP/LAG source -->

**Binding interfaces.** Select a link and use the properties panel to bind each end to a real interface. The interface picker supports multi-select on either side — tick two or more ports and a review step pairs them with the other side automatically (matched by CDP/LLDP neighbor data or by matching port-channel number), with a per-row override if the automatic match picked the wrong port. Ticking a port-channel also ticks its member interfaces. **From v2.13.13** each side also has a **clear** link next to its switch and its interface, for when a binding should be removed rather than changed — clearing the switch clears that side's interface with it (an ifIndex means nothing without its switch), while clearing just the interface leaves the switch bound. An unbound end stops producing rates, utilization bands and link events, because there's no interface left to poll; anything typed into that link's **Add subnets** box still applies.

<!-- SCREENSHOT: 46-map-interface-picker -- the interface picker showing trunk/access/neighbor filter chips and a port-channel row with its member count -->

<!-- SCREENSHOT: 49-map-port-channel-expanded -- a port-channel aggregate with its member links expanded beside it -->

**Port-channels.** A bound port-channel draws as one **aggregate** line with its physical **members** available underneath. Small **+ / -** buttons at each end of the aggregate expand or collapse the members; the collapsed/expanded state can also be set as the link's default in its properties panel (Members: Default / Collapsed / Expanded) or map-wide in Map settings. A member link always follows the aggregate's own curve. When several port-channels connect the same two devices, each one draws as its own aggregate with its own members — they never merge into a single bundle.

**Saved vs. temporary.** Dragging nodes, adding links, and everything else you do while unlocked is temporary until you click **Save**. **Discard** throws away your changes (it asks for confirmation if you have unsaved edits). Saves are global — the next person to open the map sees exactly what you saved. If someone else saved changes to the map while you were editing, Port-Sight warns you before you can overwrite them.

**Adding a port-channel.** Choosing a port-channel (Po) in the interface picker adds the aggregate link *and* one link per physical member in the same step (the row shows "+ N members"); the review step lets you check or change each member's far-side port before creating them. Members draw as lanes beside the aggregate and can be collapsed behind it with the +/- toggle on the link.

**Shaping links.** A selected link shows a small drag handle at its midpoint. Dragging it bends the link; because the handle moves freely in two dimensions, you can also flare the curve toward one end using the **Shift along link** field in the properties panel, rather than only bowing it evenly. Double-click the handle, or use **Reset**, to snap back to the automatic curve. Bending a port-channel's aggregate carries its members along with it.

**Arranging nodes.** Nodes snap to a 24px grid as you place or drag them (toggle with the **Snap: on/off** button; the snap is on the node's centre, so icons of different sizes line up on the same grid line). The grid is drawn on the canvas while you work (click **Grid** to hide it); both settings are remembered per browser. Select more than one node with Shift-click, Ctrl-click, or by dragging a marquee over empty canvas (hold Shift to add to the current selection), then drag any of them to move the whole selection together, or click **Align to grid** to snap the selection cleanly. To pan the editor canvas, hold **Space** and drag, or drag with the middle or right mouse button; a hint in the bottom-left corner of the canvas reminds you. **Undo** steps back through your edits within the current editing session.

**Copy, paste and duplicate.** With one or more nodes selected, **Ctrl+C** copies them, **Ctrl+V** pastes a copy offset slightly from the original (paste again for another copy, each one stepped further), and **Ctrl+D** duplicates in one step. Links between copied nodes come along; links to nodes outside the selection do not. Switch bindings, icons, labels and on-click actions are kept, so duplicating a configured node is a quick way to stamp out a row of similar devices.

### 10.5 Icons and drill-downs

<!-- SCREENSHOT: 47-map-icon-picker -- the icon picker open on a switch node, showing the built-in icon library grid with treatments -->

Every switch/router/firewall/cloud node can have its own icon:

- The **built-in icon library** has icons for common device types, each in several visual treatments.
- **Uploaded icons** — your own images — are managed through the asset library (Image / icon in the palette, or the icon picker's upload option).
- If a node has no icon of its own, it falls back to the **default icon** an admin set for its kind (Admin → App Settings → Network Map Default Icons), or a plain built-in outline if no default is set either.

**On click.** Every switch-bound node (and plain Icon nodes) has an **On click** setting with three options: open the bound **switch page**, **open a map** (drill down), or **open a URL** — each with its own choice of **New tab** or **Same tab**. If a switch-bound node has no On click override, clicking it opens that switch's page by default.

**Marking an area on a map (v2.14.31).** The palette has an **Area / box** entry for marking a
section of the map — a building, a floor, a data centre. Pick it, then **press and drag on
the canvas** to draw the rectangle you want (a plain click drops a default-sized one). It is not a
network link: it carries no traffic, never appears in Link Events, is not polled, and the link
tool ignores it. Areas always sit **behind links and devices**, so anything you place on top of
one stays clickable.

Its properties panel sets the **fill colour** and **fill opacity**, the **border** colour,
opacity, width and style (solid, dashed, dotted), and the **corner radius**. Tick **Border
matches fill** to keep the outline the same colour as the inside. Every colour has a swatch
and a text box that accepts a hex value such as `#2a6f97`. Give the box a label and position it
above or below like any node; the label's **size** and **bold** are settable too.

(The **Line / arrow** entry that briefly appeared in v2.14.29 and v2.14.30 has been removed; it
had no clear use and did not behave the way people expected.)

**Stacking order.** Every node has **Send to back** and **Bring to front** in its properties
panel, and they work on a multi-selection. Order is saved with the map. Annotations are
ordered among themselves; they never rise above a link or a device.

**Editing several at once (v2.14.29).** Drag a box around part of the map to select
**nodes** (that marquee deliberately ignores links). To work on several **links**, click
one and then **Ctrl-click** each of the others. The panel then offers the settings that
make sense in bulk — label position (including A end and B end), label orientation,
colour, and Straighten — and applies them to all of them in one step that a single
Undo reverses.

Where the selected items disagree on a setting, the field reads **Mixed**. Leaving it
alone keeps every item's own value; only the fields you actually change are written. So
setting the label position on ten links of five different colours leaves all five
colours intact.

**Palette changes (v2.14.30).** The NetFlow entry is now named **Top Talkers (exporter)**,
which is what it does: bind it to a switch that exports NetFlow and clicking it opens Top
Talkers for every subnet behind that switch. The separate **Action icon** entry is gone —
an Icon node with **On click** does the same job. Maps that already contain one keep
working.

**Resizing (v2.14.28).** Select a node in the editor and drag any corner handle to resize it. Device icons -- switch, router, firewall and the NetFlow icon -- stay square as you drag, since the glyph is drawn to the smaller of the two sides; image, text and cloud nodes resize freely. You can also type exact values into **Width** and **Height** in the node's properties panel. Before v2.14.28 device icons were pinned to one size.

**Label position.** A node's **Label position** setting places its label below the icon (the default), above it, to the left, to the right, or hides it entirely — useful for tightly packed layouts or icons that already carry a name.

**Subnets of interest: tick, add, or stop deriving.** A link's properties panel has a **Subnets of interest** section showing the same derived list the viewer's hover displays, plus three ways to shape it:

- **Tick or untick** what Port-Sight found (see "Pruning what gets watched" below) — for a derived subnet you don't want watched.
- **Add subnets of interest (from v2.13.7)** — a box below the checkbox list where you can type in subnets Port-Sight missed, one per line: a network (`10.1.122.0/24`), a VLAN id (`122`) looked up from the switches Port-Sight has polled, or `permit` / `deny` lines (see [chapter 14](#14-top-talkers)). These are **added to** the derived list — the typical case is a building-core-to-campus-core trunk, which only derives the building core's own access VLANs even though it actually carries every floor behind that building core too. A typed network shows as the networks Port-Sight knows inside it plus **The rest of** that range, all tickable; delete its line to remove it. Use `#` for comments.
- **Derive from the switches** (v2.15.10) — a checkbox on the Derived group's header. Untick it when Port-Sight's derivation is wrong across the board for this link: nothing is derived, now or later, and only the lines you typed are watched. (This replaces the old Override box, which did the same thing with a second list.)

The panel also shows which end it considers downstream.

**Available — tick to watch (from v2.13.8).** Below the checkbox list, the panel shows what *could* be behind this link too, unticked, so you don't have to type anything into Add subnets for the common case. The typical trunk this helps with is the same building-core-to-campus-core one mentioned above: ticking is usually faster than typing in the floors' VLANs by hand. Two groups:

- **VLANs found on a switch behind this link** — one hop past the downstream switch (excluding this link's own far end). For a building core's uplink, that's its floor switches — exactly what actually crosses the trunk.
- **VLANs known to this switch** — whatever's in the downstream switch's own VLAN database, once the first group is accounted for. With VTP server/client this list can be long (a switch can carry the whole domain's VLAN database even for VLANs it never passes traffic for), so past 20 entries it's collapsed behind a **"Show N more VLANs known to this switch"** button.

**Select all / Deselect all (from v2.13.13).** Ticking hundreds of boxes one at a time is what this is for — the owner's own case was a VTP-wide "VLANs known to this switch" list. Each group has its **own** pair of links with the number they would change (**Select all (37)**, **Deselect all**): one for the derived list, and one for each of the two Available groups. There's deliberately no single control across every group at once, because the groups don't mean the same thing — "select all" on a 300-entry VTP list is almost never what you want applied to everything else too. A bulk tick obeys the same overlap rule as a single one (see the admin guide's section 13): everything that can be watched safely goes on, anything that would overlap something already watched is left unticked, and a red line below the heading says how many were skipped and names the first conflicting pair. Rows an admin has ignored fleet-wide are never touched, a hand-added row is never unticked (delete its line in **Add subnets** instead), and the controls are disabled on a port-channel member that's still inheriting its aggregate's list. The count covers the whole group, including the part collapsed behind "Show N more VLANs known to this switch."

Tick a row here and it moves up into the main list, watched, same as anything derived — untick it again and it drops back down to "Available." **Watching N of M** only counts watched and available rows (not the ones you've unticked or an admin has ignored fleet-wide elsewhere on the panel). **Reset** clears both your unticks and your ticks on this link. A row an admin has ignored fleet-wide (see "Pruning what gets watched" below) never shows up here either — it's not offered as a candidate at all.

**Pruning what gets watched (from v2.13.0-beta.10).** Every derived subnet gets its own checkbox — ticked means "watch this one," and a **Watching N of M** count sits above the list. Untick a row (your management VLAN, a large wireless network, a guest range — anything that doesn't belong in Top Talkers) and it's removed from what the collector tracks, the viewer hover, and the Top Talkers chips for *this link only*; the row stays visible, just greyed out and marked "unticked here," and a **Reset to defaults** link (v2.15.12) puts the whole section back to a brand-new link: ticks, typed subnets of interest, the Remote ACL and the derive switch. A row can also show **"ignored everywhere"** instead — that one was pruned fleet-wide by an admin on the Flow Collector page (see [the admin guide](new-admin-guide.md) section 14), so it can't be re-ticked here; click **Change** to go turn it back on there.

**Pruning on a port-channel applies to its members too (from v2.13.3).** A port-channel's physical member links don't derive their own subnet list from scratch — each one follows the **aggregate** link's pruning/override until it's given one of its own. Select a member link with nothing of its own ticked off and its Subnets panel shows the same (disabled) checkboxes as the aggregate, with a note that it's **"Inherited from the port-channel link (edit it there)."** To prune just that one member differently, click **Prune this member separately** — it copies the aggregate's current untick list onto the member so it becomes independently editable; untick or re-tick rows on it from then on without touching the port-channel. A member with its own list shows a **Follow the port-channel again** link that clears it, handing pruning back to the aggregate.

**The NetFlow icon.** Place a **NetFlow icon** node and, optionally, bind it to a switch — its Subnets section then prefills with whatever's derived for that switch, with the same tick, add and derive controls described above. **From v2.13**, clicking the icon in the (locked) viewer opens the [Top Talkers panel](#14-top-talkers) for its subnets directly, instead of navigating anywhere.

### 10.6 Map settings

Click **Map settings** (from the list page, or while editing) to change:

- **Name** and **Description**.
- **Width** / **Height** of the canvas, and a **Background image**.
- **Root map** — whether this map is shown first in the maps list.
- **Display** options: the **Link label** shown on every link (Rate, Utilization %, Both, or None), whether to **Show interface names on links**, whether to **Show capacity label at link midpoint**, and whether to **Collapse port-channel members by default** map-wide.
- **Delete map** — removes the map and everything on it. This cannot be undone.

The **link colour bands** themselves (yellow/orange/red utilization thresholds, see [10.1](#101-what-a-map-shows)) aren't per-map — they're a fleet-wide default an admin sets once under **Admin → App Settings → Link Colour Bands**.

<!-- SCREENSHOT: 48-map-settings -- the Map settings modal showing the Display section -->

**Canvas colour and dots (v2.14.31).** By default the map sits on the page background and
shows a faint dotted grid, which is unobtrusive in dark mode and much more visible in light mode.
Map settings has a **Canvas colour** (a swatch plus a hex box; **Follow theme** puts it back) and a
**Dotted background** switch. Both apply to the viewer and the editor, and are saved with the
map. The editor's own **Grid** button is separate: it is a drawing aid, remembered per browser,
and never shown to viewers.

### 10.7 Export PNG

The viewer page has an **Export PNG** button that renders the current map — nodes, links, and labels — to a PNG image sized to fit the content, ready to drop into a slide or a ticket.

### 10.8 The Neighbors tab

<!-- SCREENSHOT: 52-switch-neighbors-tab -- a switch's Neighbors tab listing CDP/LLDP neighbors per local port -->

Every switch page has a **Neighbors** tab listing what CDP and LLDP discovered on each local port (remote device, remote port, platform, protocol, first and last seen). (The fleet-wide Neighbors report was retired in v2.14.20 — the tab, Find Host and the map editor cover what it was for.) Neighbours that match a switch in your inventory link to that switch's page; the map editor's link suggestions and Find Host draw on the same data. Each neighbour row also shows the far end's **IP** when it advertises one (CDP's management address, or LLDP's management address from v2.12.2); click it to look the device up in Find Host.

### 10.9 Tips


- **Bind the B-side switch first.** When adding several links from one switch, binding the far end (B side) first lets you add multiple links from the near end in one pass — binding A first only unlocks the same shortcut in the other direction.
- **Run a poll after upgrading.** Neighbor (CDP/LLDP) and port-channel membership data feeds the multi-switch "Also link them" suggestions and the CDP-matched interface picker. If a map you just built shows no suggestions, run **Poll Hardware** (or **Poll All**) once so that data exists.
- **A link showing no data** usually means one end isn't bound to a real interface yet — open its properties panel and bind both sides. If it's already bound, check the hover tooltip: "fleet-poll average, no recent sample" means the link poller hasn't sampled it yet (wait for the next interval), and an admin can confirm Map Link Polling is turned on under App Settings.

---

## 11. Find Host

Find Host answers one question: which switch, and which port, is a given device connected to right now? It searches Port-Sight's own polling data and, if your organization has one or more Catalyst Center systems configured, those too, for a match on an IP address, a MAC address, or a hostname.

A found host’s card also carries **Talking to, last 15 min** when the flow collector is on; it opens the host’s own Top Talkers (see [chapter 14](#14-top-talkers), v2.15.20).

### 11.1 Searching

**Sidebar:** Monitor → **Find Host**

Type an IP address, a MAC address, or a hostname into the search box and press **Enter**. A MAC address can be entered in any of the common styles — colon (`aa:bb:cc:dd:ee:ff`), hyphen (`aa-bb-cc-dd-ee-ff`), Cisco dotted (`aabb.ccdd.eeff`), or plain hex with no separators (`aabbccddeeff`) — Find Host recognizes all four. A hostname is resolved to an IP address before Port-Sight searches for it. The search terms are also carried in the page's URL, so a Find Host search can be bookmarked or shared as a link and re-runs automatically when opened.

<!-- SCREENSHOT: 60-find-host-search -- the Find Host page with a MAC address typed into the search box -->

### 11.2 Reading the results

Results are grouped by source — one group labeled **Port-Sight poll**, plus one group for each Catalyst Center you have configured, labeled with that system's name. Each result card shows whatever it knows:

- **Switch** and **Interface** — linked to that switch's and that interface's own pages, when the switch is in Port-Sight's inventory. If a Catalyst Center reports a switch Port-Sight doesn't manage, the card still shows the switch's name with a **not in Port-Sight inventory** note instead of a link.
- **VLAN** and **Description** — the port's VLAN ID and port description, when known.
- **MAC**, **IP**, and **Hostname**, plus how long ago the host was last seen there.

A wireless result from a Catalyst Center — a client connected over Wi-Fi rather than to a switch port — is marked **Wireless** and shows **AP**, **SSID**, and **Band** in place of a switch and interface.

<!-- SCREENSHOT: 61-find-host-result-agree -- Find Host results for a MAC found by both Port-Sight and a Catalyst Center, showing the "Sources agree" banner -->

When two or more sources respond, a banner above the results reads either **Sources agree** — every source points to the same switch and port — or **Sources disagree — the host may have moved; newest first** — the sources point to different ports. Disagreement most often means the host moved recently and one source's data hasn't caught up yet; results are listed newest-seen first, so the top card is usually the current location.

### 11.3 Signing in to a Catalyst Center

If your admin set a Catalyst Center up for **each user signs in** rather than a shared account, Find Host shows a small sign-in box — **Username**, **Password**, **Submit** — for that system instead of its results, the first time you search. Signing in exchanges your credentials for a session token that is held only in server memory for that session; your password itself is never stored. Once you submit, the search re-runs automatically and that system's results appear alongside the rest.

### 11.4 Not found

If nothing turns up, Find Host says so, and lists which Catalyst Center (if any) was checked and couldn't be reached. A few things commonly explain a miss:

- **The host has been idle for a while, or Port-Sight hasn't re-checked recently.** A switch forgets a MAC address once it hasn't seen traffic from it for a few minutes (commonly around 5). A sleeping laptop, or a device unplugged a short while ago, may simply have aged out of every switch's MAC table. Separately, Port-Sight itself only re-reads each switch's MAC table on its own schedule — twice a day by default — so a device that showed up (or moved) since the last run won't appear until the next one; your admin can also trigger a run immediately.
- **The switch needs one more line of configuration.** Some switches need an extra SNMP configuration line before Port-Sight can read their MAC table at all — see your admin, or the switch's own page, which flags this when it applies.
- **The device only shows up via ARP.** If Port-Sight knows a device's IP-to-MAC pairing but no switch reports it on a port, the switch actually holding that MAC on a port is most likely one Port-Sight doesn't poll, or isn't permitted to read the MAC table from — again, one for your admin.

### 11.5 Admin: Catalyst Center and MAC table coverage `Admin only`

Admins configure Catalyst Center systems and can see fleet-wide MAC table health.

**Sidebar:** Admin → Network → **Catalyst Center**

Add a Catalyst Center with its **Name**, **Base URL**, and **Authentication** mode (a shared **Service account** or **Each user signs in**), then use **Test** to confirm Port-Sight can reach it. Find Host works without any Catalyst Center configured — it just won't have anything beyond Port-Sight's own polling data to show.

<!-- SCREENSHOT: 62-admin-catalyst-center -- Admin > Catalyst Center page with a configured system and its Test result -->

Admin → Network → **Polling** shows a fleet-wide **MAC table coverage** line — how many switches are reading their MAC table successfully, and how many need the extra configuration line (`snmp-server group <v3-group> v3 priv context vlan- match prefix`, on the group your Port-Sight user belongs to). Each switch's own page shows the same status as a small chip. **Show N switches not OK** lists every switch that is not reading, with what each status means and, from v2.14.23, the actual SNMP error behind a *failed* or *unauthorized* read — so "add the context line to this switch" or "this one times out" is right there instead of in the server log. From v2.14.24 a switch whose whole read runs out of time is recorded as *failed — timed out* rather than staying "never"; a VLAN the switch has no context for (an internal VLAN such as 4094) is skipped rather than counted as a failure; and **non-Cisco switches** (Dell, HP, Juniper and the like) have their MAC table read in one plain walk, since they never answer the per-VLAN form Cisco uses — no context line is needed on them.

<!-- SCREENSHOT: 63-polling-mac-coverage -- Admin > Polling showing the MAC table coverage line -->

---

## 12. Capacity Trends

Capacity Trends answers a longer-range question than the rest of Port-Sight: not "is this port unused right now," but "is this link headed toward running out of room, and when." It tracks a chosen set of interfaces over months, fits a trend to how busy they're running, and projects forward to when a link is likely to reach 70% of its own capacity — enough lead time to plan a speed upgrade before it becomes urgent.

### 12.1 What's tracked, and when data appears

Capacity Trends only tracks interfaces you've opted into — it isn't every port on the fleet:

- **Map-bound interfaces are tracked automatically.** Any interface bound to a link on a Network Map is already sampled every 5 minutes for the map, so it's tracked for trending too, with no extra step.
- **Track utilization checkbox.** Any interface's own page has a **Track utilization** checkbox — check it to add that one interface to the 5-minute sampling.
- **The `track` tag.** Tagging an interface `track` (by hand, or with a tag rule — e.g. "track every port-channel on a building core switch") has the same effect as the checkbox, at fleet scale.

<!-- SCREENSHOT: 72-interface-track-utilization -- the Interface Detail page showing the "Track utilization" checkbox -->

Once an interface is tracked, a **nightly roll-up at 00:20 UTC** turns that day's 5-minute samples into one row of daily statistics (average, 5th/95th percentile, busy-hour average, peak, and a business-hours average). The first roll-up after tracking starts also **backfills** earlier days from Port-Sight's existing 4-hour fleet-poll history, so a chart isn't empty on day one — those backfilled days are coarser (no real 95th percentile, just an average) and are drawn **muted** on the chart to mark them as lower-resolution than days sampled since tracking began.

**Boards count too (v2.14.35).** An interface on any capacity board is tracked for as long as it sits there, whether or not it is on a map, has the Track utilization box ticked, or carries the `track` tag. Putting it on a board is the request to chart it. Before v2.14.35 a board tile only had data while its interface was also bound on a map, and went dark when that link was unbound.

### 12.2 Reading the rail

The left rail lists every tracked interface, grouped by switch, with a sparkline and three numbers for the direction currently selected (In or Out):

- **Last 30 days** — a sparkline of each day's busy level.
- **Busy level** — the 95th percentile of utilization for each of the last 30 days, averaged: how hard the link runs when it's busy, ignoring brief spikes and quiet overnight hours.
- **Growth/mo** — how fast the busy level is rising, from a trend fit on weekly 95th-percentile values.
- **Reaches 70%** — the month that growth rate would carry the link to 70% of its own capacity, if it keeps up.

Sort the rail by any of those (plus switch name or interface count per switch) with the sort dropdown and the ascending/descending toggle next to it. The filter box matches on switch name, interface name, or description. Each switch's group of interfaces can be collapsed individually, or all at once with **Collapse all** / **Expand all**.

**Collapsing the rail.** Click the chevron at the top of the rail to collapse it to a narrow strip, giving the chart grid the width back — handy on a smaller screen or when a board only has a couple of tiles. Click the chevron again (now pointing the other way) to expand it. Port-Sight remembers your choice.

### 12.3 Boards

Boards are named tabs of starred interfaces, so different projects or teams can keep separate sets without competing for the same view:

- **Star an interface** in the rail to add it to the active board (or remove it) — only when you own that board.
- **+ New board** creates one, named on the spot.
- **Drag a tab** to reorder your boards, or focus a tab and press **Alt+Left** / **Alt+Right**.
- Each of your own boards has a small menu (next to its name) offering **Rename**, **Share with everyone** (makes it visible, read-only, to every user, and marks the tab "shared"), and **Delete**.
- Boards someone else shared with you appear as their own tabs, labeled with the owner's name; you can view them but can't star interfaces onto them, reorder their tiles, rename, or delete them.

<!-- SCREENSHOT: 70-capacity-trends-board -- the Capacity Trends page showing the rail, board tabs, and a grid of chart tiles -->

**A tile that says "Nothing to chart" (v2.14.34).** Boards only chart interfaces that are being tracked. If an interface on a board stops being tracked — its **Track utilization** box is unticked, its `track` tag is removed, or it is retired or deleted — the tile says so instead of charting stale data. Tick Track utilization again to resume, or use **Remove tile**.

### 12.4 The charts

Each tile in the grid is one tracked interface's chart for the active board, in the direction (In / Out / Both) and range (3 / 6 / 12 months / all) you've picked. The grid itself belongs to the board (from v2.11): its owner sets **Columns** (1 to 4; new boards start at 2) and **Rows** (1 to 10), and every cell is a slot that either holds a tile or sits empty. Empty slots are drawn as dashed cells and stay exactly where you leave them, so a layout like two full columns and a half-empty third one is yours to keep; everyone viewing a shared board sees the owner's arrangement. A tile shows:

- A shaded **band** from the weekly 5th to 95th percentile, with an **average** line running through it.
- A horizontal **capacity** line, when the interface's speed is known.
- **Backfilled** days/weeks, drawn muted, wherever the history predates tracking.
- A fitted **trend line**, extended forward into a widening **projection cone**, with a callout reading either "Need 8 weeks of data" (not enough weekly history yet to fit a trend), "Trend flat" or "Trend rising" (no capacity to project against, or growth without a usable slope), or "70% around \<Month Year\>" once there's enough to project a date.
- A **Day / Week** toggle for the band/average display — the trend fit and projection always run on weekly 95th-percentile values regardless of which is selected.

With **Both** directions selected, In and Out stack on one shared y-scale per tile, so the two are visually comparable.

**Moving tiles.** On a board you own, drag a tile by its header onto any cell: an empty cell takes it ("Move here"), an occupied cell swaps the two ("Swap"); tiles never shuffle along on their own. If you would rather not drag, the tile's **Move** menu shows a miniature of the board's cells and moves the tile to the one you pick, and a focused tile responds to **Alt+Arrow** keys by stepping into the neighbouring cell (swapping if it is taken). Starring an interface puts it in the first empty slot, adding a row when the board is full (up to 10); unstarring leaves the slot empty. Shrinking the columns or rows below what the tiles need moves the displaced tiles into the first empty slots instead of losing them. Moving is disabled on a board someone else shared with you.

**Full screen and zoom (v2.11).** Click anywhere on a tile's chart (or its expand button in the tile header) to open that chart nearly full screen over the board, with the same Range, Granularity and Direction controls. Close it by clicking outside, pressing **Esc**, or the close button; the board underneath is untouched. Inside the full-screen view (and on the expanded page) **drag left-to-right across either chart** to zoom both charts to those dates; drag again to tighten further; **double-click** or **Reset zoom** to go back to the full range. The dotted trend line and the projection cone are not re-fitted when you zoom (they come from the full weekly history), you just see the part inside your window.

<!-- SCREENSHOT: 73-capacity-trends-fullscreen -- one chart opened nearly full screen over the board, Fit scale, with the capacity-off-scale note -->

**Scale.** The y-axis normally runs from zero to the interface's speed, so a line's height *is* its share of the link. A 5 Gb/s flow on a 100 Gb/s link is a sliver at that scale, so the **Scale** switch (in the board toolbar for every tile at once, and in the full-screen view and expanded page for one chart) offers **Fit**: the axis tightens to just above the highest value in view (and follows your zoom). In Fit mode the capacity line is off the chart and the corner note says so; the busy-level percentages in the header do not change. Scale is a viewing choice for you alone and is not saved: every visit starts back on Capacity, and nothing you pick here changes what anyone else sees on a shared board.

### 12.5 Expanded view

Click an interface's name (in the rail or on a tile) to open its own Capacity Trends page: the same chart, larger, stacked In over Out, plus a period-by-period table (p5, average, p95, busy hour, sample count, and resolution — 5-min or 4h backfill — per week or day). **Export CSV** downloads that table for the selected range; **Print / PDF** opens the browser's print dialog with just the chart and table, no sidebar or navigation.

<!-- SCREENSHOT: 71-capacity-trend-expanded -- the expanded Capacity Trends page for one interface, showing the chart and the weekly table -->

### 12.6 Tips

- **Why 95th percentile, not average.** A link running at 5 Gb/s for 8 hours a day and 100 Mb/s the other 16 has a 95th-percentile busy level of 5 Gb/s — the number that matters for planning — but an average of only about 1.7 Gb/s, which would hide the problem. Capacity Trends always plans against the 95th percentile; the average line is shown for context, not used in the projection.
- **"Need 8 weeks of data"** means exactly that — the trend fit needs at least 8 weeks of weekly 95th-percentile values before it'll extend a line forward. A newly tracked interface (or one whose only history so far is backfilled) shows this callout until enough real weeks accumulate.
- **A port-channel member's chart shows "member of PoN"** under its identity line. Track the member itself for per-link detail, or track the port-channel (via the checkbox or the `track` tag) instead for the aggregate view.


---

## 13. SSH Terminal

**Available from v2.10.** Open a terminal to a switch straight from its page, no PuTTY and no copying the management IP.

### Opening a terminal

<!-- SCREENSHOT: 05-switch-detail -- the switch page header with the SSH button next to the IP address -->

On any switch's page, next to the IP address in the header, administrators see an **SSH** button. It opens the terminal in a **new browser tab**, so you can keep the switch page or a map open beside it and hop between the two.

The new tab asks for your **own** SSH username and password (the username is pre-filled with your Port-Sight login; change it if the switch knows you by another name). Press Enter to connect. Port-Sight passes the credentials straight to the switch for that session and forgets them the moment the session starts: it never stores them, never writes them to any log, and never shows them again. Every command you run is accounted on the switch under your own name, exactly as if you had used PuTTY.

<!-- SCREENSHOT: 80-ssh-terminal -- the terminal tab's sign-in view: switch name and IP in the header, username pre-filled, password field -->

Once connected the terminal fills the tab. It behaves like any SSH client: arrows, tab completion, `?`, paging, colours, and it resizes with the window. **Disconnect** closes the session; **Reconnect** opens the sign-in form again (password required each time). **Copy session log** copies everything on screen and in the scrollback to the clipboard.

**Copying and pasting (v2.14.28)** follows the conventions you already know from PuTTY. **Selecting text with the mouse copies it** straight away -- there is no second step. **Right-click pastes** whatever is on the clipboard. `Ctrl+Shift+V` also pastes, if you prefer the keyboard. Plain `Ctrl+C` and `Ctrl+V` are left alone, because the switch needs them (`Ctrl+C` interrupts a running command). `Ctrl+Shift+C` copies in Firefox and Edge; in Chrome that combination is reserved for the developer tools and cannot be used by a page, so there, selecting is the way to copy.

Browsers guard clipboard access, so the first paste in Chrome or Edge asks your permission. Firefox does not let a web page read the clipboard at all: there, use the browser's own `Ctrl+V`.

### Host keys

The first time Port-Sight connects to a switch it records the switch's SSH host key (the header shows the fingerprint with a **first seen** badge). On later connections the key must match, the same protection PuTTY gives you. If a switch's key changes (replaced hardware, re-imaged, a new key generated), the terminal refuses to connect and shows the new fingerprint. An administrator who knows the change is legitimate clicks **Accept new key and reconnect**; the new key is pinned from then on.

### Limits and good to know

- Administrators only. Read-only Port-Sight users do not see the SSH button.
- An administrator can turn the whole feature off in **Admin > Settings** ("SSH terminal"), for sites where the Port-Sight server is not allowed to reach switches over SSH; the button disappears everywhere.
- One terminal per switch per person, and 20 open terminals per Port-Sight server.
- A terminal closes after **30 minutes without typing**, and when your Port-Sight sign-in expires (you get a warning two minutes before). The screen contents stay so you can copy them.
- Port-Sight does **not** record what you type or what the switch answers. Session accounting belongs to your AAA server (ISE, RADIUS, TACACS+), which sees these sessions like any other SSH login.
- Only switches in the Port-Sight inventory can be reached, on their management IP, port 22. The Port-Sight server itself must be allowed to reach the switches on TCP 22 (it already reaches them for SNMP).
- "Could not reach ... on port 22" usually means an access list or firewall between the Port-Sight server and the switch, or SSH not enabled on the switch, the same things that would stop PuTTY from the server.

---

## 14. Top Talkers

**Available from v2.13.** "Who is using this link right now?" Utilization bands tell you a link is busy; Top Talkers tells you who. Port-Sight runs its own NetFlow/IPFIX/sFlow collector (a separate container, `port-sight-flow`) so this works without a third-party flow tool.

The Top Talkers window is a floating panel rather than a dialog: it opens wide enough to show each conversation on one line, you can drag it by its header and resize it from its bottom-right corner, and the page behind it stays usable, including the assistant, so you can ask about what you are looking at while it is on screen. Its position is remembered for the session; double-click the header to reset it. Escape closes whichever of the two has focus.

### In plain words: the two boxes on a link

A link's Top Talkers is defined by two boxes in the map editor, both written like an access list, one entry per line, `#` for comments.

- **Subnets of interest** are the subnets this link is monitored for. Top Talkers lists every conversation these subnets have, in both directions. Most links fill this in on their own from the switches at each end. A typed network means the whole range; Port-Sight lists the subnets it knows inside it plus “the rest”, and you untick what you do not want. A `deny` line above a network cuts a hole in it.
- **Remote ACL** is optional and applies to the remote end of each conversation. First match wins, implicit deny, and an empty ACL permits any. A subnet of interest is never the remote end.

Four links on one site core, as a worked example with made-up addresses. Our own site is 10.1.0.0/16, a hosted partner is 10.2.0.0/16, a parent organisation owns the rest of 10.0.0.0/8, the wider campus is 10.3.0.0/16, a cloud tenant is 10.200.0.0/16 and the DMZ is 192.168.0.0/16.

| Link | Subnets of interest | Remote ACL |
|---|---|---|
| To the parent organisation | `deny 10.2.0.0/16` `deny 10.1.0.0/16` `10.0.0.0/8` | empty |
| To the hosted partner | `10.2.0.0/16` | empty |
| To the campus | derived from the switches | `permit 10.3.0.0/16` `deny 10.0.0.0/8` `permit 0.0.0.0/0` |
| Internet edge | `10.0.0.0/8` `192.168.0.0/16` | `permit 10.200.0.0/16` `deny 10.0.0.0/8` `deny 192.168.0.0/16` `permit 0.0.0.0/0` |

Read the parent-organisation line as: anything in 10/8 that is not our site or the hosted partner, talking to anyone. A conversation between 10.7.1.1 and 10.1.1.1 is listed there; one between 10.1.1.1 and 10.2.1.1 is not, because neither end is a subnet of interest on that link. Read the campus line as: our site talking to the campus or the internet, but not to the rest of our own 10/8, which leaves over the other links. The edge line lists 10.x and the DMZ talking to the internet or the cloud tenant, and nothing inside-to-inside. The cloud permit sits above the 10/8 deny on purpose, since it is inside it.

The rest of this chapter explains the mechanics and the limits.

### Opening the panel

<!-- SCREENSHOT: 81-map-top-talkers -- the Top Talkers panel open over a map, showing subnet chips, the sparkline, and a conversations table -->

On a map, two places open the panel:

- **A link's Top Talkers glyph** — a small circle with a double-arrow icon at a link's midpoint, shown only when that link has at least one subnet behind it and the feature is turned on fleet-wide; the two halves of the link stop at its rim, so their arrowheads point at it. Click it.
- **A NetFlow icon** — a dedicated node kind an admin can place on a map (usually bound to a switch). Click it and the panel opens for that switch's own subnets directly, instead of navigating to the switch page.

<!-- SCREENSHOT: 83-map-flow-icon -- a NetFlow icon on a map next to its Top Talkers glyph -->

### What the panel shows

- **Subnet chips** across the top — a link or icon can sit behind more than one subnet; pick which one you want. A `?` on a chip means Port-Sight couldn't fully confirm which subnet is correct for that VLAN (see [10.1](#101-what-a-map-shows)) — the data is still real, just unconfirmed. **From v2.13.0-beta.10**, a subnet pruned on this link (unticked in its Subnets panel) or ignored fleet-wide (Admin → Network → Flow Collector's "Ignore everywhere" card) never gets a chip here — see [10.5](#105-icons-and-drill-downs); **from v2.13.3**, a port-channel member link with no pruning of its own uses whatever's pruned on its aggregate instead, so its chips match the Po's unless the member has been pruned separately; **from v2.13.7**, a subnet typed into a link's **Add subnets** box gets a chip here too, same as any derived one.
- **The "All" chip (v2.13.10).** When a link or icon watches more than one subnet, an **All** chip sits first in the row and is picked by default — it shows every subnet currently watched on that link combined into one set of conversations, ranked across all of them together (not three separate top-25 lists glued together — the ranking happens before trimming, so a talker that's #5 overall but only #30 within any one subnet still shows up). It always follows whatever is ticked right now: untick one subnet and tick another, and All immediately means the new set — nothing is remembered as a fixed list. A single-subnet link has no All chip; its one subnet behaves exactly as before. Hover the chip (or the "All subnets on this link" line under it) to see which subnets it covers.
- **A ticked candidate can never overlap another watched subnet (v2.13.10, narrowed in v2.15.6).** Ticking a candidate that sits inside, or contains, something already watched is refused — pick one or the other. Typed lines are exempt: a typed range deliberately contains the networks under it, and `permit` / `deny` lines are an ordered list, so they are never checked for overlap.
- **Exporter selector** — shown only when more than one exporter (a core switch, a firewall, ...) has data for the chosen subnet. **Exporters are never combined.** The same flow often crosses both the core and a firewall on its way through your network, so summing them would double the real traffic; the panel always shows one exporter's own view at a time. Each option reads `<name or IP> — 1.2 GB`, or `<name or IP> — no traffic` for an exporter that has a record but hasn't actually sent any bytes in the window (listed last).

### Which exporter opens by default

**From v2.13.2.** With more than one exporter in play, the panel has to guess which one you actually want open first. It picks, in order:

1. **Your choice** — if you've picked an exporter for this exact link or NetFlow icon before, Port-Sight remembers it (stored in your browser, per link/icon) and reopens it automatically next time, as long as that exporter still has data.
2. **Matched to a switch on the link** — otherwise, if exactly one of the available exporters is bound (Admin → Network → Flow Collector) to one of the two switches the link connects (or, for a NetFlow icon, the switch it's bound to), and that exporter actually has traffic, it opens.
3. **Most traffic** — otherwise, whichever exporter has the most bytes in the window opens.

An exporter with **no traffic** (a record exists — some devices, like a Cisco FTD's NSEL "created" events, log a flow before any bytes are counted — but nothing has actually been sent) is never chosen by default while another exporter has real data, even if it's your previously-remembered choice or matches a switch on the link. The small line under the dropdown ("Default: your choice" / "Default: matched to &lt;name&gt;" / "Default: most traffic") says which of the three picked the one you're looking at. You can always switch manually; your pick is remembered for next time.
- **A 15-bar sparkline** of the last 15 one-minute buckets — inbound bytes above the axis, outbound below, with the busiest minute labeled.
- **In / Out tabs.** "In" is traffic heading toward the subnet you picked; "Out" is traffic leaving it.
- **Conversations / Hosts toggle.** Conversations lists individual flows: local IP, remote IP, protocol, port, bytes, packets, and flow count, sorted by bytes, top 25. Hosts rolls the same window up to one row per remote IP, for a quicker "who's talking the most" read.
- Every IP address links to **Find Host**, so you can go straight from "what" to "which port on which switch."
- **Source → Destination (v2.14.23).** The conversations table reads left to right the way a flow does: the left column is the sender, the right the receiver, and a small *local* tag marks whichever side is an address in the subnet behind this link. Under **In** (traffic into the subnet) the local address is the destination; under **Out** it is the source.
- **Where each talker is (v2.14.22).** Under every address Port-Sight can place, a small line says which switch port it is plugged into — `HSF3-2 Gi1/0/14 · Lab 312` — from the same MAC and ARP tables Find Host uses (chapter 11), with the port's description when it has one. Click it to open that interface. Hover for when it was last seen there. An address that only shows up on an uplink reads "beyond SW Te1/1/1": the host is somewhere past that port, on a switch Port-Sight does not poll. Addresses the MAC tables cannot place are then asked of Catalyst Center (when one is set up and you are signed in to it), a few seconds later: a wireless client reads "wireless, AP *name*"; a wired one shows the switch and port Catalyst Center reports. Addresses outside your network have no line — the Find Host link is still there.
- **In a stored link-event snapshot** (chapter 15) the port under an address is where it was plugged in **when the event fired**, saved with the snapshot — never a lookup made when you open it, which days later could name whoever holds that address by then.

### The port shown is always the server side

A conversation's **port** column is the *server-side* port — whichever of the two ports in a flow looks like the well-known one (`445 smb`, `443 https`, `3389 rdp`, and so on). The client's own ephemeral port (a random high number picked fresh for each connection) is deliberately dropped from the row. Without this, one backup job talking to `10.10.5.20:445` would show up as 400 near-identical rows, one per TCP connection, instead of the single row that actually answers "what is this."

### Timing

The window covers the **last 15 minutes**, refreshed automatically every 60 seconds while the panel is open (or click **Refresh**). Because exporters batch their own flow records before sending them, "now" on the sparkline is really **about a minute behind** — a normal property of NetFlow/IPFIX, not a Port-Sight delay.

### If it shows nothing

- **"The flow collector is not reachable"** means the collector container itself is down or unreachable — see Admin → Network → Flow Collector, or [Troubleshooting](troubleshooting.md).
- **"No flows for this subnet in the last 15 minutes"** usually means either no exporter is currently sending flow data for that subnet, or the exporter that sees this particular link's traffic isn't the one selected. Check Admin → Network → Flow Collector's exporters and subnets tables — see [the admin guide](new-admin-guide.md) section 14 for exporter configuration per platform.

**See also:** [chapter 15, Link Events](#15-link-events) — Port-Sight watches every mapped link and, without anyone having the panel open, writes down a top-talkers snapshot automatically whenever something notable happens.

---

**Which subnets a link watches, and why some are only offered (v2.15.0).** A link watches the networks behind its downstream switch — but only for VLANs that something there actually uses: a VLAN counts while at least one port in it is up or has carried traffic in the last 30 days. A VLAN that sits only on unused ports is not watched; it appears in the link's list under **No active port in that VLAN on this switch**, and one tick watches it anyway. Likewise, when the only network Port-Sight can find for a VLAN is an SVI far away in the fleet rather than within two hops, it is offered under **Guessed from elsewhere in the fleet** with the switch it came from, not watched by default. Before v2.15.0 both were watched automatically, which put NetFlow on links that had nothing to do with those subnets.

**Everything a core routes, in one line (v2.15.1).** On a link to a core or a firewall, what sits behind it is the device's whole routing table, not a handful of access VLANs — so the usual list comes up short. In the link's **Subnets of interest** box, type the prefix, for example `10.1.0.0/16`. If Port-Sight knows networks under it, from any switch in the fleet, they appear in the list: grouped under **Under 10.1.0.0/16**, each a checkbox marked with the switch it came from, with **Select all** and **Deselect all** for the group, kept up to date as networks come and go. The prefix itself is never watched; only its networks are. A network with nothing known beneath it is watched exactly as you typed it, as before.

**Only the traffic that crosses this link (v2.15.2, renamed in v2.15.6).** Until now a link’s Top Talkers meant “flows touching the subnets behind it, seen by any exporter”. With one exporter that attributes campus-wide traffic to links it never crossed. A link can now narrow the remote end of each conversation. In the editor, under the subnets of interest, the **Remote ACL** box is optional and takes one rule per line, `permit <network>` or `deny <network>`, read like an access list: for each remote address the rules are checked from the top and the first that matches wins; an address no rule permits is not listed (implicit deny); a subnet of interest is never the remote end. A bare address is a single host. Networks are saved at their network address (`10.3.5.0/16` becomes `10.3.0.0/16`). Leave the box empty and any remote end is permitted, as before. Comments start with `#` and are kept.

With rules set, Top Talkers lists only conversations with a subnet of interest at one end and a remote end the ACL permits, and says so above the tables. Two limits, both stated in the panel: the collector keeps the top 25 conversations per subnet per minute *before* this filter runs, so on a busy subnet crossing traffic can be cut short; and the chart still counts all traffic on the subnets of interest. The link’s hover card in the viewer lists the rules. Example: the link from a site core to the campus core gets `permit 10.3.0.0/16`, `deny 10.0.0.0/8`, `permit 0.0.0.0/0`; a conversation between `10.1.171.5` and `10.3.4.9` is listed; one between `10.1.171.5` and `203.0.113.9` is listed under the last rule; one between `10.1.171.5` and `10.7.4.4` is not.

**A typed network means the whole range, shown as what is in it (v2.15.6).** A line in the Subnets of interest box, with or without `permit` in front of it, watches the whole range. The list shows it as the networks Port-Sight knows inside it, one per row with the switch it came from, plus one row **The rest of <range>** covering everything else, so a new subnet never needs an edit. Everything is ticked by default. Untick a known network to cut a hole; untick “the rest” to keep only the known networks. A `deny` line above a network cuts a hole in it too. This is how you say “everything in 10.0.0.0/8 except our own 10.1.0.0/16 and a hosted partner's 10.2.0.0/16” on a link to another organisation:

```
deny 10.2.0.0/16
deny 10.1.0.0/16
10.0.0.0/8
```

A conversation between 10.7.1.1 and 10.1.1.1 is listed on that link, since one end is a subnet of interest and the Remote ACL is empty. A conversation between 10.1.1.1 and 10.2.1.1 is not, since neither end is in the range. Order matters only for denies: a deny below a network does not touch it.

**A preview as you type (v2.15.5).** The box shows what your lines produce as you type: the known networks, the looked-up VLAN, or the range and its rest appear in the list a moment after you stop typing, marked “Preview”, and you can untick them before saving. If the lookup fails the lines are still resolved when you save. Groups of more than 20 subnets start collapsed; the header shows the counts and the Select all / Deselect all controls work without opening the group (v2.15.7).

**Filtering the panel, and seeing the icon while editing (v2.15.12).** The Top Talkers panel has a **Filter** box (reworked in v2.15.14). Type a search line and press Enter: an address (`10.1.5.12`), a prefix with a wildcard (`10.1.*`), or a network (`10.1.0.0/16`), combined with `AND`, `OR` and `NOT` (or `!`); a space or comma between terms means OR, and parentheses group. `10.1.* AND 10.2.*` keeps conversations between those two; `NOT 10.1.5.12` hides one host. Nothing changes while you type, so you can keep reading; Enter applies, Escape clears, and the caption says how many rows are showing. It never calls the server and never changes the link, and it can only narrow what the collector already kept, the top 25 per subnet and direction. In the map editor, a link with subnets of interest now carries a small NetFlow marker at its midpoint so you can see which links have them; it ignores the mouse, so the curve handle on top of it works as before. Clicking the half of a link that has no device opens the other end’s interface page when that end is bound.

**Rates, not just bytes (v2.15.19).** Each conversation row shows **Avg over 15 min**, the byte count spread evenly over the whole window as a bit rate, and **Peak minute**, the busiest single minute the collector saw, with “seen N of 15 min” under it. A transfer that moved 70 GB reads as 622 Mbit/s on average; if it was really a three-minute burst, the peak minute says so. Hold the average against the link’s own utilisation chart when a number looks too big to be true.

**A host’s own top talkers (v2.15.20).** On **Find Host**, a found host’s card has a **Talking to, last 15 min** button, and in the command palette typing an address offers **Top talkers for that address**; both open the same Top Talkers panel with the host at the centre: In is traffic into the host, Out is traffic out of it, across every watched subnet and every exporter at once. The limit is the collector’s: it keeps the top 25 conversations per watched subnet per minute, so a quiet host that never makes a subnet’s top 25 is not there, and the panel says so rather than showing an empty table.

## 15. Link Events

**Available from v2.13.** Top Talkers (chapter 14) answers "who is using this link *right now*" when you open the panel. Link Events answers a different question: "why did this link get busy last Tuesday at 2am, and who was on it?" — without anyone having to be watching at the time.

Two triggers, each with its own defaults (all adjustable on **Admin → Settings → Link Events**):

- **Band crossed** — a mapped link's live utilization rises into (or above) a configured minimum colour band. Default: **orange**. Rising into yellow, on its own, doesn't record anything unless you lower the minimum band.
- **Above normal** — a link's 5-minute rate runs more than **50%** over the top of its own learned **normal range for that hour of that weekday**, and is also above **25% of that link's capacity** (so a 10 Gb/s link idling at 1% and doubling to 2% is not an event, however "abnormal" the doubling). "Normal" is learned automatically overnight, per interface and direction, as 168 hour-of-week slots — so Port-Sight knows that a link idling at 3% overnight, running 10–25% through the working day, and jumping to 70% every Friday night is doing exactly what it always does, and only a departure from *that* pattern is an event. See "What 'normal' means" below.

Neither of these ever sends an email, a chat message, or any other kind of alert (an explicit design decision) — this is a record you consult when you want to know what happened, not a notification that interrupts you.

### What a snapshot is

The moment either trigger fires, Port-Sight asks the flow collector for the same top-talkers data chapter 14 shows live — up to the top 10 conversations in each direction, for up to 3 subnets behind that link — and saves it with the event. Months later, opening that event's snapshot shows exactly who was using the link at that moment, even though nobody had the Top Talkers panel open at the time.

A snapshot can also say it has **nothing to show**:

- **"collector unreachable"** — the flow collector container wasn't reachable at the moment the event fired.
- **"no flows"** — the collector was reachable, but had no flow data for this link's subnets in the 15 minutes before the event (nothing was exported, or the wrong exporter sees this link's traffic).
- **"no subnets"** — this link has no subnets derived behind it, so there was nothing to ask the collector about.

### Reports → Link Events

<!-- SCREENSHOT: 84-link-events-report -- the Link Events report with filters, the events table, and the snapshot button -->

An event belongs to the **physical link** — the two interfaces — not to a particular map. If you draw the same uplink on two maps (a campus overview and the building's own map, say), a crossing is recorded **once**, and the row's Map column lists every map that draws that link; filtering by either map finds it.

The report lists every recorded event, newest first, 100 per page:

- **Filters:** map, event type (chips for Band crossed / Above normal), a date range (last 24 hours / 7 days / 30 days, or a custom range), and a text filter on the link or map name.
- **Columns:** Time (shown relative, e.g. "12 min ago" — hover for the exact time in your display timezone), Map, Link (both link to the map), Kind, Direction, Value (the reading that triggered the event, e.g. `84% · 8.4 Gb/s`), Reference (what it was compared against, e.g. `red band (85%)` or `normal 300 Mb/s`), Duration (how long a band-crossed event stayed above the band before it fell back — "ongoing" while it's still active, since above-normal events are instant readings with no duration), and Snapshot.
- **Snapshot column:** click **View** to open the stored top-talkers snapshot in a read-only version of the same panel chapter 14 describes. When there's nothing stored, the column explains why (see "What a snapshot is" above) instead of a button.
- **Time** shows the exact date and time first, with "18 h ago" underneath, so an event can be matched against a chart.
- **Link** opens the map, as before; the two lines under it — **A: switch port** and **B: switch port** — open each end's own interface page with its 5-minute chart. The **Value** column also says which counter the figure was read from ("from SW-A Te1/1/1 out"): an A → B event is A's outbound counter, a B → A event is B's.

**Checking an event against the chart.** The event's figure *is* one 5-minute reading of that counter, so the same spike must appear on that interface's chart at that time. If it does not, the reading was bad rather than the traffic real — and from v2.14.15 Port-Sight catches most of those itself: both ends of a wire count the same bytes, so A's outbound and B's inbound must agree; a reading more than twice what the other end saw (a port-channel whose member re-joined and brought its lifetime counter along, an interface number that moved, or a link whose two ends are not actually the same wire) is distrusted and records no event. The snapshot, by contrast, is NetFlow: the conversations the exporter saw for the subnets drawn behind the link over the 15 minutes before the event. It need not add up to the counter — it covers only those subnets and only what the exporter sees, and a 15-minute total is not a 5-minute rate.

<!-- SCREENSHOT: 85-link-event-snapshot -- a link event's stored top-talkers snapshot, opened read-only -->
- **Export CSV** exports every event matching the current filters (not just the current page).

### Acknowledging events **`Admin only`**

An event you have looked at and are done with can be **acknowledged**: it leaves this report's default view and the map's "Events (24 h)" count, but stays on record — the row keeps who acknowledged it and when, and the CSV still includes it. Tick **Show acknowledged** to see them again (dimmed), and *undo* on a row to bring one back. Acknowledge one event with the button on its row, or tick several (the header box ticks everything shown) and use the bar that appears above the table.

The same bar offers **Delete** for events you know are junk — a link that was bound to the wrong interfaces, say. Deleting is permanent and asks you to confirm; when in doubt, acknowledge instead.

Opening a Top Talkers panel from a map also gets a small **Recent events** link, taking you straight to this report already filtered to that one link.

### What "normal" means

For every tracked interface and direction, Port-Sight keeps a **normal range for each hour of the week** — 168 slots, Monday 00:00 through Sunday 23:00, in your display timezone (so "Friday 8pm" stays Friday 8pm across daylight-saving changes). Each night it folds the previous day's 5-minute samples into their slots and keeps, per slot, that week's typical level (the median sample) and ceiling (the 95th percentile). The slot's "normal" is then the **median across the last 8 weeks** of those two figures: a range from *typical* to *ceiling*, not a single number.

Two consequences of using the median are worth knowing:

- **One unusual week cannot move it.** A one-off maintenance window, a holiday, or the very week an event fired is included in the data but is outvoted by the other weeks — the range stays where most weeks put it.
- **A change that lasts becomes the new normal.** Once a new pattern has held for more than half the kept weeks (five of eight), it *is* the range, and the old pattern is forgotten as it ages out.

An "above normal" event fires against the **ceiling** of the current hour's range, plus the margin and the capacity floor — not against the typical level, which half of all hours would exceed by definition.

### The normal range on charts

- On the **Capacity Trends** detail chart, the range appears as a shaded band labelled "Normal range (hour-of-week)". A trend point covers a whole day or week, so the band there is the envelope of that weekday's (or week's) trusted hours — lowest typical to highest ceiling.
- On an interface page's **5-minute samples** chart, the band follows the exact hour: each sample sits over the typical-to-ceiling band for its own slot, so you can see the moment a reading climbed out of it.
- The dashed **30-day high-water** line is still drawn for reference ("the busiest this link has been in a month") but it no longer raises events.

### The first four weeks

A slot has to see **four weeks** of data before its range is trusted. Until then that hour is **silent**: Port-Sight raises no "above normal" event for it at all, rather than comparing against a number it does not yet trust — an event called "above normal" must not quietly mean "above the monthly peak". Charts show "normal range learning: N of 4 weeks" while this is the case, and the Link Events report says so in its empty state. Band-crossed events work from day one, since they don't depend on learned history.

### Two honest limits

- **Holidays and semester breaks will look abnormal.** The profile knows weekdays, not the academic calendar: the first Monday of a break looks like a very quiet Monday, and the Monday classes resume looks busier than the eight quiet weeks before it. Expect a few "above normal" events around those transitions and read them as what they are.
- **A one-off window pollutes its slot until the median outvotes it.** The median protects the range from a single odd week, but a pattern that repeats for several weeks (a backup job moved to a new night, say) will be learned as normal — which is the intent — and an event that fires during the week it starts is the only notice you get.

---

## 16. Availability

<!-- SCREENSHOT: 86-availability-report -- the Availability report: fleet tiles and the per-device table -->

Reports → Availability answers "how much of the quarter was this switch actually up?" — per device and for the whole fleet — and does it honestly: every figure is a **range**, because that is what the checks can support.

### Where the numbers come from

Port-Sight checks every switch two ways:

- **The regular poll** (every 4 hours by default) has always asked each switch for its `sysUpTime` — how long the device has been running since it last booted.
- **The heartbeat** (every 5 minutes by default, adjustable or switchable off by an admin) asks *only* that one question of every switch, with a 3-second timeout. It is a tiny request, far cheaper than a poll, and it records nothing at all unless something changed.

Both feed the same record of **down / up / reboot** moments per device. A device is marked **down** the first time a check gets no answer (a single missed heartbeat counts — the report's ranges absorb the odd timeout rather than hiding it behind a second try), **up** when a check succeeds again, and **rebooted** when its uptime says it booted since the last good check.

### Why a range, and what a reboot pins down

When a check fails at 10:05 after a good one at 10:00, the device went down *somewhere* in those five minutes; when it answers again at 10:20 after failing at 10:15, it came back somewhere in *those* five minutes. So the outage lasted anywhere from 10 to 20 minutes, and the report says exactly that: a **best case** (10 min) and a **worst case** (20 min), and availability as "99.87% – 99.94%" rather than one number the data cannot support.

With the heartbeat running, the two numbers differ by minutes. With only the 4-hour poll, they differ by hours — a missed poll could mean the device was down for a few minutes or for nearly eight hours, which was exactly the problem this report was built to solve.

**A reboot narrows the range to the second.** `sysUpTime` is a clock that starts at boot, so a device reporting "up 23 minutes" at 10:20 booted at 09:57 — precisely — however far apart the checks around it were. When an outage ended in a reboot, its end is pinned to that moment and the device page says "pinned by a reboot". A reboot that happened entirely between two good checks (the device went down and came back before anyone noticed) still shows as an outage ending at its boot time, with a best case of zero and a worst case reaching back to the previous good check.

### The report

- **Period presets and date pickers:** last 30 days, last quarter (the previous calendar quarter), this quarter, last 12 months, this year — or any range: the **From** and **To** date pickers beside the preset always show the period in force, and changing either one makes it a custom range of whole days. Everything on this page — the presets, the pickers, every timestamp, and the PDF — is in the **display timezone** set under Admin → Settings (the period line at the top says which); the checks themselves are stored in UTC underneath. "This quarter" means what it means on your wall clock.
- **Long lists fold.** The events panel and a device's outage list open collapsed, with a count; click *show* to expand.
- **Fleet summary:** average availability across the measured devices (as a range), how many devices had any outage, how many reboots, how many are down right now, and how many have **never been reached** — not checked yet, or checked but never once answered (wrong credentials, wrong address). Those are counted, never treated as down, and never part of the average: Port-Sight has never reached them, so it cannot say whether they are up or down. A switch added with the wrong credentials therefore does not drag the fleet figure, whether or not it is in maintenance; the row still says *never answered · authentication failed* so you know what to fix.
- **Per device:** availability (worst – best), downtime (best – worst), outages, reboots, the longest outage (worst case), the device's current state, and when it was last seen. Sort any column; filter by name, IP, or location; **Export CSV** writes the table as shown.
- **Export PDF — the report for IT leadership.** A document written to be handed on, not a dump of the table: a cover with the period, a plain-English summary ("…monitored 451 production network switches. Taken together they were available 99.93% – 99.96% of the time — the equivalent of about 1 h 20 min of downtime per switch over the 92 days"), the six headline figures, a short "how to read these figures" box, and the longest outages of the period; then a section per **site tag** with that site's own figure, a line summing it up, a table of only the switches that had something happen (an outage, a reboot, planned maintenance, or down at the time), and "all other N switches had no outage". Switches with no site tag come last under "Not assigned to a site". It covers the period and the site pills in force on the page, so a one-site report is one click away; the file is named after the period. Run it quarterly and send it on.
- **Click a device** for its outages and reboots in the period. Each outage shows the window it started in and the window it ended in, and *why* each window is as wide as it is — "between the last good check and the first failed one (heartbeat)", "4-hour poll — no heartbeat was running", "pinned by a reboot at …", or "still down".
- A device **first checked inside the period** is measured from its first check, and the row says "(since …)".
- An outage that straddles the period boundary counts only the part inside the period.

### Maintenance and non-production devices

A lab switch that is rebooted ten times a week should not drag the fleet's availability down, a test bench that is powered off most of the time should not show as a fleet outage, and a core you are about to take down for a code upgrade should not count against you while you do it. Port-Sight ships two **built-in switch tags** for exactly this, created with the application and impossible to delete or rename:

- **maintenance** (amber) — temporary: the clock is paused while it is on. Tick it before planned work and untick it after, or set a window for a number of hours and let it come off by itself.
- **non-production** (grey) — permanent: lab gear, test benches, spares. Left out of the fleet figures altogether.

Both kinds of device are **still checked and still listed** — the row shows an amber "maintenance" or grey "non-production" label, sorts and filters like any other, you can open its outages, and the CSV export carries `maintenance`, `non_production` and `time_in_maintenance` columns. The difference is what happens to the figures:

- A **non-production** device is **left out of the fleet tiles** (its row is greyed). A line under the tiles says how many were left out.
- A device in **maintenance stays in the fleet**. The time it spends in maintenance is taken **out of the measured period**, and any downtime inside that time is **not counted** — so a switch that was in maintenance for two hours last month is judged on the other 718 hours, and whatever it scored over those hours counts towards the fleet like everyone else's. A line under the tiles says how many are in maintenance right now; those are not in the "Down now" tile either, since being down inside a window is expected.

**Three ways to set them, one truth.** They are ordinary tags underneath, so whichever way you set one, every other place shows it:

1. **On the switch's page** — two checkboxes at the top, "In maintenance" and "Non-production" (administrators).
2. **On this report** — the **Maint.** and **Non-prod** checkboxes at the end of each row (administrators).
3. **Like any tag** — Admin → Tags, or a tag rule (Admin → Tag Rules), so "every switch named `LAB-*` is non-production" is one rule, not a chore to keep up. Unticking a device that a rule had tagged also records a "keep off" for it, so the next rule pass does not put it straight back.

An administrator can additionally choose other switch tags to be treated as non-production, under Admin → Settings → Availability ("Additional exclusion tags").

### Maintenance windows

Port-Sight **remembers when a device was in maintenance** — every span is a *maintenance window* — and that is what the figures are built on. There are four ways a window comes about, and you rarely have to think about which:

- **Tick the checkbox.** Ticking "In maintenance" (on the switch page or the report) records the moment; unticking it records the end. Nothing to type, nothing to remember.
- **Start now, for a while.** Next to the checkbox on the switch page is **⏱ for a while…**; on the report, tick one or more rows and press **⏱ Maintenance window…**. Choose **Start now** and a length (1, 2, 4, 8 hours or your own) and the device goes into maintenance immediately and comes out by itself when the time is up — ideal for "I'm about to reload this core".
- **Schedule for later.** In the same dialog, **Schedule for later** takes a start time (your local time) and a duration. The device goes into maintenance at the start and out at the end with no one watching. The switch page and the report row both show "scheduled …" until then, with a **cancel** link.
- **Afterwards.** Someone forgot. Open the device's outages (click its name), and each outage has a **This was maintenance** checkbox: tick it and that outage is discounted — a window covering exactly that outage is recorded; untick it to count it again. An outage that a real window already covers shows the box ticked and locked; an outage that is still running cannot be marked this way (tick In maintenance instead).

Setting a window for **many devices at once** is the report's job: use the search box or a site pill to narrow the table, tick the box in the table header to select everything shown (or tick rows one by one), and press **Maintenance window…** — one dialog, one window per selected device.

**One event, many switches.** When three or more switches go down within ten minutes of each other, Port-Sight treats it as one event and lists it under **Events affecting several switches at once** above the table — "Sep 28, 1:02 PM – 1:41 PM · 37 switches down together (BRB, HSF3)". **Show these switches** narrows the table to them. If it was planned work, **this was maintenance…** records a window for every affected switch covering the whole event in one go (it asks for a note); the event then shows a "planned maintenance" label and **undo** puts it back. **False alarm…** does the same but records it as a false alarm. An event that is still going on cannot be marked until it is over. Events are found across the whole fleet; with a site pill selected you still see every event that touches that site, with "2 of 5 in the selected site". The same events appear in the PDF, in words.

**"That wasn't an outage."** Sometimes you know better than the check: the switch was up, the reading was wrong. Marking that as *maintenance* would be a lie in the record, so each outage (and each event) also has **False alarm**: the reading is discounted exactly as maintenance would be, but it is labelled "false alarm", kept apart from the maintenance windows, and the PDF says "N readings were reviewed and disregarded as false alarms". Untick to count it again.

**Why is it down?** A device's row and its outage view say what the last check found: **SNMP timed out** (no answer within the time allowed — the device is off, unreachable from the server, or not answering SNMP), **authentication failed** (the device answers but refuses the SNMP credentials Port-Sight has for it — it will ping fine), or **unreachable** (no route from the server). A device that has **never answered** a single check since it was added (wrong credentials, typically) is shown as "never answered" rather than as an outage that began, is never part of an event, and is in automatic maintenance until its first successful poll. Remember what is being measured: *SNMP reachability from the Port-Sight server*, not ping.

**A miss is checked twice.** Before a switch is marked down, the heartbeat asks again with a longer timeout and a retry; only a second failure counts. One lost packet, or a device that took four seconds to answer this once, is not an outage.

**Notes, and who.** Every window records who set it, and you can say why: the timed-window dialog has a note field, and ticking **In maintenance**, **This was maintenance** on an outage, or an event always offers one. An administrator can make the note **mandatory** under Admin → Settings → Availability ("Require a note when marking maintenance") — then nothing can be marked as maintenance without saying what the work was. Notes and names show on the switch page, in the device's window list, and in the PDF.

A tag that arrives some other way — from Admin → Tags, from a tag rule, or the automatic maintenance of a never-polled switch — is recorded as a window too, from the moment it went on to the moment it came off; and a tag taken off while a scheduled window is still running ends the window there and then (whoever acts last wins). In the device's outage view, the **Maintenance windows** list shows every window touching the period and any still to come, with **end now** / **cancel** / **remove** for administrators. Removing a past window makes its downtime count again.

What a window does to the numbers, exactly: the window's time is taken out of the device's measured period and out of every outage it overlaps, in both the best and the worst case. An outage entirely inside a window stays in the list marked "during maintenance" and is not an outage in the figures; one that runs past the end of the window counts only the part outside. A reboot inside a window is listed but not counted. A device in maintenance for the whole period has no figure for it (there is nothing to judge). Link events on the maps are **not** affected: a link crossing a band during maintenance is still recorded, and still counts.

**Automatic maintenance for a new switch.** A switch that has **never been polled successfully** — typically one just added with the wrong SNMP credentials, or one the server cannot reach yet — is put into maintenance automatically on its first failed poll, labelled "maintenance (auto)". It was never up as far as Port-Sight knows, so it should not count as down. The tag lifts by itself on the first successful poll, and the time until then is a window like any other, so the days it spent unreachable never count against it. If you'd rather it counted, untick it; Port-Sight remembers that and will not put it back. A switch that *has* polled successfully before and then fails is a real outage and is never tagged this way.

**Per site.** The site pills at the top of the page (the same ones the dashboard has) narrow the whole report — tiles and table — to the switches carrying the selected site tag(s). Nothing selected means every switch.

**The tiles are filters.** Click **With an outage**, **Reboots**, **Down now** or **Never checked** and the table shows only those devices (the "N non-production devices excluded" and "N devices in maintenance right now" lines work the same way); the tile lights up and a "Showing: Down now ×" chip appears above the table. Click the chip, or the tile again, to clear. The search box still narrows within the filter.

**From the detail to the switch.** Clicking a device name opens its outages and reboots; the first line of that window has an **Open the switch page →** link for the device's full page.

### The report by email

Port-Sight can send mail from v2.14.18. An administrator sets the mail server once under **Admin → Settings → Email** (server, port, STARTTLS/SSL, a login if the server needs one, the From address) and presses **Send test**. Then:

- **Email…** beside Export PDF sends the report for the period and sites on screen, right now, to the addresses you type — the same PDF, built on the server.
- **Admin → Settings → Availability report by email** sends it on a schedule with no one watching: tick it on, list the recipients, choose what it covers (the previous quarter, the previous month, the previous week, or the last 30 days) and when (quarterly on the 1st at 07:00, say). The card shows when it last went out and, if the last attempt failed, why. The email's body is the report's own summary paragraphs, with the PDF attached.

### History from day one

On its first run, Port-Sight replays up to 400 days of its own past poll results (the 4-hourly ones it already had) through the same bookkeeping, so the report has real quarters of history immediately rather than starting empty. Those replayed outages carry the wide, hours-long ranges the 4-hour poll supports; outages from the day the heartbeat started are minutes wide.

**Right after an update or a restart** the report can look empty for a few minutes: every device shows "Never checked" because neither that replay nor the first heartbeat has run yet. The page says so — "The first check runs a few minutes after startup; history from past polls appears with it." — and the figures fill in on their own; there is nothing to click.

### The honest limits

- **Reachability from Port-Sight is what is measured.** A switch that is up but unreachable from the Port-Sight server (a WAN link down, an access list change, SNMP wedged) is "down" here. That is usually what you want from an availability report, but it is not the same as the device being powered off.
- **A device that never answered** (wrong credentials from the day it was added) is down from its first check, and its availability will say so.
- **Uptime counters wrap** after about 497 days. Port-Sight recognises the wrap and does not count it as a reboot; the one thing it cannot tell apart is a *real* reboot that happens to land within a couple of minutes of the wrap on a device that has been up that long — a once-in-sixteen-months coincidence.
- **Events are kept for 400 days** by default (an admin can lengthen it), so a full year plus margin is always available; older outages age out of the report.

---

## 17. Outages

Outages are events a person decided to document: what went down, when, who felt it, what caused it and what fixed it. They are kept apart from the Availability figures on purpose. Availability measures whether switches answered; an outage may involve no network device at all, and a switch down for maintenance is neither. Port-Sight never creates an outage from its own observations, and logging one never changes an availability figure.

### Who can log and edit

Everyone who is signed in can read outages. Who may log and edit them is a setting under *Settings > Outages*: **Admins only** (the default) or **All users**. Deleting an outage is always admin-only. Every create, edit, update and delete is written to the Audit Log with the outage's code and the names of the fields that changed, never their text.

### The list

*Reports > Outages* lists every outage, newest first: the code (OUT-2026-003), title, start, duration or an *ongoing* pill, severity, primary service, sites and cause. The filters run on the server:

- **Period** — All, Last month, Last quarter, Last 6 months, Last year, or Custom with two dates. A day means the whole day in the app's display timezone, so two people in different places see the same list.
- **Service**, **Severity** (Sev1 is the worst) and **Ongoing only**.
- **Search** — type what you remember and press Enter. It searches titles, root causes, fixes, workarounds, lessons and the update log, and ranks the best matches first.
- **Attachments** — a clip with a count marks outages that carry files.
- **Row actions** — the ellipsis at the end of a row (shown to anyone who may edit) offers *Add attachment*, which uploads straight to that outage, *Edit*, and for admins *Delete*.

Codes are assigned per year and never reused: deleting OUT-2026-003 leaves a gap, it does not hand the code to the next outage. Titles are free text and may repeat.

### The detail panel

Clicking a row opens the outage on the right (a bottom sheet on a narrow screen). It is driven by the page address, so a link to `/outages?id=...` opens the same panel. The sections follow the form: Timing (the four timestamps and the time to detect, time to restore and duration computed on the server), Impact (severity, impact type, users affected, services, sites, business impact and the devices linked to the outage), Detection, Cause, Vendor, Response, Prevention, Follow-ups and Other. Empty rows are hidden; an empty section reads *Nothing recorded.*

Two things are edited from the panel rather than the form:

- **Updates** — the *What is happening now* box appends a timestamped entry to the update log (Ctrl+Enter also adds it). Log the outage first, then narrate it from here as it unfolds.
- **Follow-ups** — tick a follow-up done. The tick is applied at once and rolled back if the save fails.

*Edit* opens the form; *Delete* (admins) asks for confirmation and reminds you the code is never reused. Escape closes the panel.

### Settings > Outages

- **Who may log and edit outages** — Admins only or All users. Saves as soon as you change it.
- **Calendar week starts on** — Sunday or Monday, for the calendar's columns and weekend tint. Saves as soon as you change it.
- **Services** (up to 50) and **Sites / departments** (up to 200) — the vocabularies the form offers. Rename inline, reorder with the arrows, remove, or add at the bottom (Enter adds too). A name that differs only by case from an existing one is refused, because two spellings would split the report's counts. *Save lists* saves both lists together. Renaming or removing an entry never changes an outage already logged.

### Logging an outage

*Log outage* opens the form in the panel; *Edit* opens the same form filled in. The sections mirror the detail view: Title, Timing, Impact, Detection, Cause, Vendor, Response, Prevention, Follow-ups and Other. Nothing is marked required. Validation runs when you save and shows one message at a time, starting with the title, the start time, at least one service and a primary service, then the time order (Start, then Detected, then Work began, then End) and the 200-character limits on the short text fields.

- **Times** are entered and shown in the app's display timezone. Start defaults to now. Detected at, Work began at and End are a date and a time box each: the date defaults to today and the time starts blank, and a blank time means not set, so leaving End's time blank keeps the outage ongoing; ending it later means filling End. A read-only line under the timestamps shows the time to detect, the time to restore and the duration as you type.
- **Services** are chips from the Settings list. The first one you pick becomes the primary (the one the report counts the outage under); the radio in a chip moves it. Typing a name that is not in Settings selects it anyway and, for admins, offers to add it to Settings. Sites work the same way without a primary.
- **Follow-ups** are rows with an action, an owner and a due date. Rows with a blank action are dropped on save.
- **Saving** a new outage sends every field; saving an edit sends only the fields you changed, so an untouched timestamp is never rewritten. If nothing changed, nothing is sent.

The update log is not on the form: log the outage first, then narrate it from the detail panel with *Add update* as the event unfolds.

### Events with no impact

A notice from a carrier about a fiber cut upstream, a vendor's incident on a path you were not using: worth a record, not an outage. Log it and set the impact type to **No impact**. The record keeps everything an outage keeps, including attachments, follow-ups and the update log, and the assistant finds it by its symptoms; the list tags it "no impact" and the calendar draws it as a hollow band. The report counts such events on their own line, "N events with no impact (recorded, not counted)", lists them in a short table of their own, and leaves them out of the outage counts, the downtime totals and every breakdown. Their open follow-ups still appear in the open follow-ups table.

### Devices on an outage

The **Devices** field in the Impact section links switches to the outage. Search the fleet by name, IP, model, location or tag and pick from the results, or add every switch carrying a tag or every switch on a map in one go. Each device gets a role: **affected** (the default) or **source**, for the device that caused the outage. Zero devices is fine; an outage may involve no network equipment at all. Archived switches can be included so history survives a replacement.

Once the start time is set, a collapsed row offers what Port-Sight observed in that window: switches that stopped answering or came back, reboots, hardware changes and link events. Nothing is ticked for you. Expand it, tick what was part of this outage, and *Add ticked* adds them as affected. A window with nothing observed says so. Observations are not a verdict; a switch in maintenance during an outage is not part of it unless you say so.

The detail panel lists the devices with links to their pages, source first. A switch's own page shows how many outages it was part of and the latest one, linking to the list filtered to that device.

### Attachments

An outage can carry files: a vendor's report, a ticket export, a screenshot. The panel header shows how many it has, and the **Attachments** section, right after Impact, lists them with size, uploader and date, with *Download* and *Remove* on each row and *Add attachment* for anyone who may edit outages. Allowed types are PDF, Word, Excel, CSV, text, Markdown and images; the type is checked from the file's own bytes, not its name. Each file is capped by **Attachment size limit** under *Settings > Outages* (20 MB by default), with at most 20 files per outage. Files are stored in the database, so they travel with backups and restores; the Health page shows how much space they take. The report lists each outage's attachments by name and size.

Cleanup is a deliberate action, never automatic: on the Settings tab, *Remove attachments from outages older than N months*, **Preview** shows how many files and megabytes across how many outages would go, and **Remove** asks you to confirm those numbers. Ongoing outages are never touched, each affected outage gets a line in its update log saying what was removed, and the run is in the Audit Log.

### The calendar

The *Calendar* view on the Outages page draws months three to a row (one per row on a narrow screen), with each outage as a band across the days it spanned, coloured by severity: Sev1 red, Sev2 amber, Sev3 the accent colour, Sev4 grey. An ongoing outage runs to today with a diagonal stripe. Overlapping outages stack into lanes, and every week of a month keeps the same height so the rows line up. Hover a band for its code, severity, title, time range and services; click it to open the outage in the panel.

Pick a **window**: 3 months, Quarter, 6 months, 12 months or 24 months. Every window except Quarter ends at the current month, so today is in the last row and the past is above it; Quarter shows the calendar quarter. *Previous* and *Next* step by the window's length, *This month* returns to now, and the Left and Right arrow keys step too. The toolbar stays pinned at the top while you scroll, so a 24-month view is never a trap. The choice is remembered on this device. Days are the app's display timezone, so an outage that ended at exactly midnight does not spill onto the next day. The first day of the week, Sunday or Monday, is set under *Settings > Outages*.

### The report

The *Report* view on the Outages page answers "what did the period cost us and why". Pick a period (Last month, Last quarter, Last 6 months, Last year, or a custom range of up to 800 days; the dates are in the address, so the report is linkable). It shows five totals (outages, total downtime, average time to detect, average time to restore, the longest outage), four breakdowns (by severity, by primary service, by cause, and the preventable share), one write-up per outage grouped under its primary service, a grid of which services each outage touched with the primary marked, and the open follow-ups. Every number is computed on the server; an outage counts once, under its primary service, with its whole duration, and an ongoing outage is measured to the moment the report was generated.

*Download PDF* fetches the same report rendered on the server, one service group per page, named after the period.

## 18. The assistant

The assistant is a chat panel inside Port-Sight that answers questions from Port-Sight's own data and from this guide. It runs on an API key your organisation supplies, so Port-Sight itself sends nothing to any model provider until an admin turns it on. It is read-only: it can look things up and explain them, and it cannot change anything.

### Turning it on **`Admin only`**

*Settings > Assistant*: enable it, pick the provider (Anthropic, or any OpenAI-compatible endpoint such as Azure OpenAI, Ollama or vLLM), set the base URL and model, and paste the API key. The key is stored encrypted and is never shown again; the tab only says whether one is set. *Test* sends one short prompt and shows the reply or the error. By default only admins see the assistant; **Open to all users** lets every signed-in user use it. **Retention** controls how long conversations are kept (0 keeps them until deleted).

### Using it

Open it from the sidebar entry *Assistant* or from the command palette ("Ask the assistant"). Type a question and press Enter; Shift+Enter adds a line. Answers stream in as they are produced. When the assistant looks something up, a status line shows which tool it is using and whether it succeeded; the panel never shows the raw lookup. Tables come with a *Download CSV* button. Links go only to pages inside Port-Sight; a link to a guide section opens that section right in the panel. Conversations are kept as threads you can reopen or delete; nothing carries between threads unless you paste it.

Things it can answer, with the tool behind each. Top talkers come from the NetFlow collector, which keeps the top 25 conversations per watched subnet per minute, so a quiet host may not appear; availability and capacity figures are the same ones the reports show.

| Tool | Category | Admin only | What it does |
|---|---|---|---|
| `search_docs` | docs | no | Search the Port-Sight user guide, troubleshooting guide and deployment guide. Returns the best sections with their anchors so the answer can link to them. |
| `search_known_issues` | docs | no | Search the list of known issues (symptom, versions affected, cause, fix or workaround). |
| `search_outages` | outages | no | Find past outages by symptom, cause or fix, optionally within a date window, for a service, severity or switch. Use for questions like 'a year ago we had similar symptoms, what was it and what fixed it'. |
| `get_outage` | outages | no | Get one logged outage in full (times, cause, remediation, update log, follow-ups, devices) by its code, for example OUT-2026-003. |
| `outage_report` | outages | no | The outage report for a date range: how many outages, downtime minutes, averages, and breakdowns by severity, service and cause. Range is at most 800 days. |
| `find_switch` | fleet | no | Find switches by name, IP address, model, location, serial number, stack member serial or service tag, asset tag or tag. Use for 'what is the IP of switch X' or 'which switch has serial / asset tag Y'. Matching is a case-insensitive substring. |
| `find_host` | fleet | no | Where is a host plugged in? Look up a MAC address (any common format) or an IPv4 address in Port-Sight's Find Host data and get the switch, port and VLAN it was last seen on. A hostname is resolved through DNS first and each address (up to 4) is searched. |
| `switch_status` | fleet | no | Why is a switch red? Its latest poll result and error (with a class such as authentication or unreachable), maintenance window, pending hardware change, heartbeat state, last boot and counted/used port totals. |
| `interface_lookup` | fleet | no | Is a port up and what is on it? One interface of a switch by name or description; short names like Gi1/0/12 work. Gives status, speed, VLAN, last change, tags and MAC count. |
| `fleet_summary` | fleet | no | Count switches grouped by model, firmware (software version), site tag or status (ok / failing / never polled / inactive). Use for 'how many switches are still on image X'. Model, firmware and site count active switches; status also lists inactive ones. |
| `query_data` | data | yes | Run a read-only SQL SELECT over Port-Sight's data to answer questions the other tools cannot. Only the views listed here exist; columns holding secrets are not present. Return at most 500 rows; prefer ORDER BY and LIMIT. One statement, no comments. Views (columns): switches(id, name, ip_address, snmp_port, snmp_version, location, is_active, deactivated_by_license, last_polled_at, last_poll_success, last_poll_success_at, last_boot_time, model, serial_numbers, ios_version, stack_members, physical_entities, base_mac, last_hardware_polled_at, asset_tag, previous_asset_tag, reload_acknowledged_at, is_archived, archived_at, archived_by_id, archived_ip, archived_name, hardware_change_detected_at, hardware_change_pending, hardware_change_candidate, mac_table_status, mac_table_polled_at, mac_table_error, created_at) interfaces(id, switch_id, if_index, if_name, if_description, if_alias, if_type, is_uplink, is_excluded, is_admin_down, notes, custom_flags, vlan_id, port_mode, if_speed_mbps, duplex, poe_delivering, poe_power_mw, track_utilization, retired_at) interface_stats(id, interface_id, last_changed_at, last_poll_at, oper_status, admin_status, in_octets_hc, out_octets_hc, in_errors, out_errors, last_in_kbps, last_out_kbps, last_in_errors_delta, last_out_errors_delta, created_at, updated_at) interface_poll_snapshots(id, interface_id, switch_id, poll_timestamp, last_changed_at, admin_status, oper_status, in_kbps, out_kbps, in_errors_delta, out_errors_delta, created_at) poll_runs(id, switch_id, poll_event_id, polled_at, success, switch_uptime_seconds, interfaces_found, interfaces_updated, total_ports, active_ports, error_message) tags(id, name, color, border_color, text_color, scope, category, is_reserved, created_at, updated_at) tag_assignments(id, tag_id, target_id, assigned_by, rule_id, created_at) vlans(id, switch_id, vlan_id, name, updated_at) switch_subnets(id, switch_id, if_index, if_name, vlan_id, ip, prefix_len, network, last_seen) switch_neighbors(id, switch_id, if_index, protocol, remote_name, remote_port, remote_platform, remote_mgmt_ip, capabilities, is_infra, neighbor_switch_id, first_seen, last_seen) maps(id, slug, name, description, width, height, background_asset_id, is_root, display, version, created_by, updated_at) map_nodes(id, map_id, kind, label, x, y, w, h, icon_asset_id, switch_id, drill_map_id, drill_url, style, z_order) map_links(id, map_id, a_node_id, b_node_id, a_switch_id, a_if_index, b_switch_id, b_if_index, capacity_bps, label, style) map_link_samples(id, link_id, sampled_at, a_to_b_bps, b_to_a_bps, a_oper_up, b_oper_up) link_events(id, map_id, link_id, occurred_at, kind, direction, band, value_bps, reference_bps, pct, subnets, snapshot, snapshot_status, resolved_at, created_at, acknowledged_at, acknowledged_by) switch_availability_events(id, switch_id, kind, at, prev_ok_at, prev_attempt_at, uptime_seconds, source, note, created_at) switch_heartbeat_state(switch_id, state, first_attempt_at, last_attempt_at, last_ok_at, last_uptime_seconds, down_since_attempt_at, last_error, updated_at) maintenance_windows(id, switch_id, start_at, end_at, source, note, created_by, tag_applied_at, created_at) outages(id, short_code, title, started_at, detected_at, work_began_at, ended_at, severity, impact_type, services, primary_service, sites, users_affected, business_impact, detected_by, reported_by, cause_category, root_cause, vendor, vendor_ticket, rfo_received, workaround, remediation, updates, preventable, avoidance, proactive, monitoring_gap, follow_ups, related_ticket, lessons, review_date, created_by, updated_by, created_at, updated_at) outage_devices(outage_id, switch_id, role) capacity_boards(id, user_id, name, position, shared, columns, rows, created_at) capacity_watchlist(id, user_id, board_id, interface_id, position, slot_row, slot_col, created_at) host_locations(id, mac, switch_id, if_index, vlan_id, source, first_seen, last_seen) host_ips(id, ip, mac, source_switch_id, first_seen, last_seen) flow_exporters(id, ip, name, switch_id, first_seen, last_seen, records_total) interface_daily_stats(id, interface_id, day, direction, avg_bps, p5_bps, p95_bps, busy_hour_bps, peak_bps, business_hours_avg_bps, samples, resolution, created_at) interface_profile_weeks(id, interface_id, direction, week_start, slot, p50_bps, p95_bps, samples) |
| `top_talkers` | network | no | What are the top talkers on subnet Y, host Z or the link between A and B right now? Reads the NetFlow collector's last minutes (1 to 15). Give exactly one of subnet (CIDR), host (IP) or link (the two end names, e.g. 'SW-A - SW-B'). Direction 'in' is traffic into the subnet or host, 'out' from it. Port-Sight keeps only the top 25 conversations per watched subnet per minute (top talkers, not every conversation), so an empty or short answer does not mean no traffic. Use this, not the map, for 'top NetFlow talkers'. |
| `link_utilisation` | network | no | How busy is the link between A and B? The map link found by the names of its two ends: rates each way, percent of capacity, health, the reading's age and unacknowledged link events in the last 24 hours. |
| `availability` | network | no | What was site S's (or switch X's, or the fleet's) availability last month? Best and worst case percent, downtime, incident count and maintenance time over the last N days, from the same figures as the Availability report. |
| `capacity` | network | no | How many ports does switch X have left? Counted, used and free ports for one switch (name or IP), or the tracked interfaces of a Capacity Trends board with their latest utilisation. With neither, the five fullest switches in the fleet. Used means up now or changed within the days threshold. |
| `diagnose` | diagnosis | no | Explain why something is not working from Port-Sight's own state: a switch that is red, the NetFlow collector, polling, the licence. Returns findings with a next step. |
| `dns_lookup` | network | no | Resolve a hostname to its addresses, or an address to its name, using the Port-Sight host's DNS. Use it alongside find_host, top_talkers(host=...) and search_outages when asked everything about an address. |

The assistant answers only from what those tools return. When it cannot find something it says so rather than guessing, and it never invents device names, numbers or outage codes. If an answer looks wrong, the status lines tell you which lookup it relied on.

### Asking about the data directly **`Admin only`**

For questions none of the fixed lookups cover, such as "list every switch without an asset tag" or "which switches are still on SNMP version 2", the assistant can query Port-Sight's data with SQL it writes itself. The query runs against a set of read-only views that leave out every column holding a secret (the SNMP community and passwords, password hashes, API keys), in a transaction the database itself refuses to let write, with a five-second limit and at most 500 rows. The raw result sits under the lookup's status line, collapsed to one line ("Query: 14 rows") with *Download CSV* and *Download PDF* buttons; *Show data* expands the SQL it ran and the table, so you can judge the query, copy it, and run it yourself later. Tick **Always show query data** at the top of the panel to have every result expanded on this device. The *Data schema* link in the panel header lists the views and columns the assistant can reach. Only admins get this tool, whatever the Open to all users setting says.

### Names and addresses

Ask "tell me everything about 10.1.20.45" and the assistant combines its lookups: where the address is plugged in, its DNS name, what it talks to in the last fifteen minutes, and any outage it was part of, and says which parts had no data. A hostname works too: it is resolved first, then searched. Top talkers tables show a name beside each address where one resolves. Names come from the Port-Sight host's own resolver, so a name that only your workstation knows will not appear, and reverse lookups on private addresses depend on your internal DNS holding the records.

### Asking why something is wrong

"Why is switch X red?" or "Why is the collector not receiving flows?" runs Port-Sight's diagnosis rules over its own state and answers with findings in plain words, each with a next step: credentials the switch refuses, timeouts, a maintenance window, a hardware change waiting for an admin, a heartbeat that disagrees with the last poll, a collector that is unreachable or idle, the licence, an update waiting, a scheduled job that has stalled, switches still on SNMP version 2. The same rules run when a support bundle is built, so a bundle carries the findings of the moment it was made.

### Sending a bug report

The flag icon in the panel header opens *Send a bug report*. Describe what happened; the draft shows the subject and body it will send, including the last exchange with the assistant and the current findings, and names the support bundle it attaches (version, health, settings without secrets, recent poll results, the switch list with poll state, collector and scheduler state, and the server's network and clock facts as of the last daily maintenance run; switch names redacted). If email is configured under *Settings > Email*, **Send** mails it to Port-Sight support with you as a recipient too. If not, **Download bundle** and **Open in your mail app** give you the same message to send yourself. Nothing is sent until you click.

### What leaves your network

Only your questions, the tool results the assistant needed to answer them, and this guide's relevant sections are sent to the model provider you configured, under your key. Switch credentials and password hashes are never readable by any tool. If you have not configured a key, nothing is sent anywhere.

## Glossary

**95th percentile** — the value below which 95% of a day's utilization samples fall; Capacity Trends' "Busy level" is this value, not the average, because it reflects how hard a link runs when it's actually busy without being hidden by quiet overnight hours or brief spikes. See also: *Busy hour*.

**Action icon** — a small clickable icon placed next to a node or link on a Network Map. Clicking it opens a URL — commonly a link out to another monitoring tool — independent of what the node or link itself does when clicked.

**Active port** — an interface whose admin status and oper status are both "up" at the time of the most recent poll. An active port is currently linked and passing traffic (or at least ready to). See also: *Used port*.

**Admin status** — whether an interface has been administratively enabled (`up`) or shut down (`down`) by a network administrator via the switch CLI or management platform. A port that is admin-down will never show as operationally up regardless of whether anything is plugged in.

**Age (days since last active)** — the number of days since an interface last had operational activity (a status change recorded via `ifLastChange`). A port showing "45d" has been inactive for 45 days. A port showing "Active" is currently up. A port showing "Never" has no recorded activity in Port-Sight's database.

**Aggregate (port-channel)** — a bundled link on a Network Map that represents a port-channel: one drawn line standing in for multiple physical member links. The aggregate can be expanded to show its individual members or collapsed to a single line; members follow the aggregate's curve automatically.

**ARP (Address Resolution Protocol)** — the protocol a network device uses to look up the MAC address that owns a given IP address on its local network segment. Port-Sight reads a switch's ARP table, where available, to pair an IP address with a MAC address for Find Host.

**Board** — a named, user-owned tab on the Capacity Trends page holding a set of starred interfaces and their tile order. A board can be shared (read-only for everyone else) or kept private; the interfaces themselves keep tracking either way if a board is deleted.

**Busy hour** — the highest rolling 1-hour average utilization seen in a day, tracked alongside (but separate from) the 95th percentile. Shown as an alternate line on the Capacity Trends detail chart via the "Busy-hour series" checkbox. See also: *95th percentile*.

**Canned report** — one of the pre-built report cards on the Report Builder's Canned Reports tab. Each canned report is a fixed set of conditions (e.g., "EoL Status = expired") that you can run with one click. Clicking Run loads the conditions into the Custom Query tab where you can refine or save them.

**Canonical name** — the official VLAN name for a specific site, set on the VLANs page by starring a VLAN row. Used to detect naming mismatches across switches in the same site.

**Catalyst Center** — Cisco's network management system. Port-Sight can optionally query one or more Catalyst Center systems (configured on Admin → Network → Catalyst Center) to enrich Find Host results with usernames, wireless client details, and device health beyond what Port-Sight's own polling collects.

**Chassis** — a single physical switch unit. A standalone switch is one chassis. A stack of 5 switches is 5 chassis managed as one logical switch. Fleet Overview counts chassis, not management points.

**Condition** — a single filter rule in the Report Builder's Custom Query, consisting of a field (what to check), an operator (how to compare), and a value (what to compare against). Multiple conditions are AND-combined.

**Conversation** — one flow (or the merged view of several flows sharing the same local IP, remote IP, protocol, and server port) in the Top Talkers panel's Conversations table. See also: *Exporter*, *Server port*.

**Critical report** — a saved report marked with the critical flag (red alert icon). Critical reports appear in red on the Dashboard instead of cyan, drawing attention to problems that need immediate action.

**Days threshold** — the inactivity window used throughout Port-Sight to decide whether a port is "used" or "unused." A port that has been inactive longer than the threshold is counted as unused. Adjustable on the Switches page, Capacity Planner, and Reclaim Report via a dropdown (30 / 60 / 90 / 120 / 180 / 240 / All Time / Custom).

**Drill map** — a map opened by clicking a node (typically a cloud) that has an "Open map" click target configured. Drilling shows a more detailed view — a building, a closet, a datacenter — while breadcrumbs at the top let you navigate back up the chain.

**Duplex** — the communication mode of an interface. Full-duplex means the port can send and receive simultaneously. Half-duplex means it alternates. Half-duplex on a modern network is almost always a misconfiguration and commonly causes errors.

**Emergency Location (E911)** — the Hardware Assets tab (admins only) that exports one row per switch — base MAC, description, location — for emergency-call location services such as Microsoft Teams or an E911 LIS. The export records a baseline; later hardware changes show as "N changes since your last E911 export" until you export again.

**End-of-life (EoL)** — the manufacturer's announced date after which a switch model is no longer supported. Port-Sight tracks EoL dates per model and shows badges on Fleet Overview, Hardware Assets, and Firmware Versions pages.

**Entity-MIB** — the SNMP MIB that provides physical component inventory: chassis, modules, power supplies, fans, sensors, stack members. This is the data source for the Hardware Inventory tab and the Hardware tab on the Switch Detail page.

**Exclude tag** — a reserved interface tag. Ports tagged `exclude` are hidden from all reports by default. Use this for management interfaces, stack links, or any port you never want to appear in capacity calculations.

**Exporter** — a device (a core switch, a firewall, ...) sending NetFlow, IPFIX, or sFlow records to Port-Sight's flow collector. The same physical flow is commonly seen by more than one exporter (a core and a firewall both see the same crossing traffic); the Top Talkers panel always shows one exporter's own view, never a sum of several. See [chapter 14](#14-top-talkers).

**Fernet key** — the encryption key (stored in `.env` as `CREDENTIAL_ENCRYPTION_KEY`) used to encrypt SNMP credentials at rest in the database. If this key is lost, stored SNMP passwords become unreadable and must be re-entered.

**Golden image** — on the Firmware Versions page, the firmware version you designate as the standard for a given switch model by clicking the star icon. This is a per-user visual marker stored in browser local storage — it doesn't push any configuration to switches.

**Hardware inventory poll** — the polling cycle that collects Entity-MIB data (chassis, modules, power supplies, fans, serial numbers). Runs independently of interface polling, typically monthly or quarterly.

**ifAlias** — the SNMP object representing the interface description set by a network administrator (via the `description` command on Cisco). Shown as "Description" or "Alias" throughout Port-Sight. Example: `LL-013 Printer`.

**ifLastChange** — the SNMP object representing when an interface last changed operational state (up→down or down→up), expressed as a timetick relative to the switch's boot time. Port-Sight converts this to an absolute UTC timestamp and uses it to compute port age.

**Installation ID** — a unique identifier generated on first startup (format: `PSI-XXXXXXXXXXXX`). Stored both on the filesystem and in the database. Used for license machine-binding — a license issued for one installation ID will not validate on a different server.

**Interface polling** — the primary polling cycle that collects per-port data: status, speed, duplex, VLAN, traffic counters, errors, and `ifLastChange`. This is the data that drives most reports.

**Label** — a switch-scope tag used for grouping and filtering. Labels appear as colored pills in the Label Filter dropdown on report pages. See also: *Site tag*.

**Label Filter** — the pill bar that appears at the top of most report pages, showing all switch-scope tags. Click pills to filter the page to switches matching the selected labels. Multiple selections use OR logic (any match).

**MAC table** — the table a switch keeps, mapping each MAC address it has seen to the port it was seen on. Port-Sight periodically reads this table from each switch to power Find Host. Entries age out of a switch's own MAC table after a period of inactivity, commonly around 5 minutes.

**Member link** — one of the individual physical links bundled inside a port-channel aggregate on a Network Map. Shown when the aggregate is expanded; hidden (rolled into the aggregate's single line) when collapsed.

**mGig (Multi-Gigabit)** — interfaces capable of speeds between 1G and 10G (2.5G, 5G) on copper. Port-Sight highlights mGig-capable ports on the Switch Detail page for models that support it.

**Oper status** — whether an interface is operationally up or down. A port can be admin-up but oper-down (nothing plugged in or link failure). A port that is oper-up has an active link.

**Peak active** — the highest number of simultaneously active ports seen on a switch during any single poll within the selected time window. Shown on the Switches page and Dashboard. This number can exceed the current "used" count because it captures the historical maximum.

**Phantom port** — an interface reported by SNMP for an empty network module slot. These interfaces exist in the switch's interface table but don't correspond to physical ports. Port-Sight detects phantom ports via Entity-MIB and tags them as excluded so they don't inflate port counts.

**PoE (Power over Ethernet)** — the ability of a switch port to deliver electrical power to connected devices (access points, IP phones, cameras). Port-Sight shows PoE status with a lightning bolt icon and the power draw in watts.

**Poll run** — a single polling event for one switch. Each poll run is recorded in the History tab with timestamp, success/failure status, interfaces found, interfaces updated, and any error message.

**Port mode** — whether an interface is configured as `access` (carries a single VLAN) or `trunk` (carries multiple VLANs via 802.1Q tagging). Shown as colored badges: teal for access, purple for trunk.

**Reclaim report** — the Capacity Planning report that lists every unused port fleet-wide, grouped by switch, for the purpose of cleaning up stale configurations. Designed to be printed or exported as a change-ticket attachment.

**Reserved tag** — one of the three built-in interface tags (`uplink`, `exclude`, `admin-down`) that have special meaning in Port-Sight's filtering and counting logic. Reserved tags cannot be renamed or deleted.

**Sample (vs. fleet average)** — the two sources a Network Map link's rate can come from. A **sample** is a direct 5-minute (admin-configurable) measurement taken by the map-link poller for interfaces bound to a map; the **fleet average** is the roughly 4-hour average from the regular polling cycle, used as a fallback when no recent sample exists. Hovering a link half shows which one you're looking at.

**Saved report** — a Custom Query saved with a name in the Report Builder. Saved reports are refreshed nightly by the scheduler, and their result counts are stored for display on the Dashboard.

**Server port** — in the Top Talkers panel, whichever of a flow's two TCP/UDP ports looks like the well-known/listening side (e.g. `445` for SMB), shown instead of the client's own random ephemeral port. This is what lets Port-Sight collapse hundreds of individual connections from one client into a single meaningful row. See [chapter 14](#14-top-talkers).

**Site tag** — a switch label with its category set to "Site." Site tags have extra capabilities: they appear as filter pills on the VLANs page, can scope tag rules to specific sites, and are shown in bold in the Label Filter to distinguish them from regular labels.

**SSH Terminal** — a browser-based SSH session to a switch, opened with the **SSH** button on the switch page (administrators only, Chapter 13). You sign in with your own credentials, which are never stored; the switch's host key is pinned on first use.

**Stack** — multiple physical switch chassis managed as a single logical unit. Port-Sight treats a stack as one switch for management purposes but counts each chassis separately for hardware inventory. A 5-member stack counts as 1 switch on the Switches page but 5 chassis on Fleet Overview.

**Tag rule** — an automated rule that assigns a tag to interfaces or switches based on a regex pattern and optional AND conditions. Tag rules run after every poll cycle and can be manually triggered from the Tag Rules admin page.

**Trunk port** — an interface configured to carry traffic for multiple VLANs simultaneously using 802.1Q VLAN tagging. Trunk ports typically connect switches to each other, to routers, or to servers requiring access to multiple VLANs.

**Unused port** — an interface that has not been active within the configured days threshold. The opposite of a *used port*. Unused ports are the focus of the Switches page, Capacity Planner, and Reclaim Report.

**Uplink** — an interface connecting one switch to another switch, a router, or a core device. Uplinks are tagged (manually or via tag rules) and excluded from unused-port calculations by default, since they serve infrastructure purposes and should never be "reclaimed."

**Uplink auto-protection** — the automatic tagging of ports as `uplink` when CDP/LLDP neighbor data shows they connect to another switch or router. Auto-protected ports are excluded from unused/reclaim reports the same as manually tagged uplinks. Controlled by an admin setting. See also: *Uplink*.

**Used port** — an interface that has been active within the configured days threshold. A port counts as used if it is currently active (admin up + oper up) OR if its last state change (`ifLastChange`) falls within the threshold window. A port can be operationally down right now but still count as "used" if it was active 10 days ago and your threshold is 90 days.

**VLAN (Virtual Local Area Network)** — a logical network segment within a switch. Ports are assigned to VLANs to separate traffic. Port-Sight tracks VLAN assignments per interface and provides the VLANs report page for fleet-wide VLAN analysis and naming consistency checks.

**VPAT (Voluntary Product Accessibility Template)** — a document that evaluates a product's conformance to accessibility standards (WCAG 2.1 AA). Required by procurement teams at public universities and government agencies under Title 2 ADA compliance.

**Watched report** — a saved report that has been favorited (starred). Watched reports appear as cards in the Dashboard's Watched Reports section, showing the report name and the result count from the last nightly refresh.
