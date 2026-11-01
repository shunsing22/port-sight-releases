# Port-Sight Privacy Policy

**Effective date:** June 17, 2026

This Privacy Policy explains how **KABIN Labs LLC** ("KABIN Labs", "we", "us") handles information in connection with the Port-Sight software ("Software"), the `port-sight.com` website, and our license issuance and validation service at `keys.port-sight.com` (together, the "Services").

## The short version

Port-Sight runs on **your** infrastructure and monitors **your** network devices. **Your operational data never leaves your systems.** The only information we receive is what you provide when you buy or contact us, plus two non-sensitive license identifiers your installation sends to validate its license. We do not sell your data.

## 1. Information we collect

**a. Purchase and account information.** When you buy a license, our payment processor (Stripe) collects your name, email address, billing address, and (if provided) business name, phone number, and tax ID. We receive this information to issue and manage your license. **We do not receive or store your full payment card details** — those are handled by Stripe.

**b. License validation information.** An activated online installation periodically contacts `keys.port-sight.com` to validate its license. During validation it transmits **only (i) the license identifier and (ii) a randomly generated installation identifier.** The installation identifier is a random value, not derived from any personal or hardware information. No network, device, configuration, SNMP, usage, or personal data is transmitted during validation. (Offline-exempt licenses transmit nothing.)

**c. Support communications.** If you email us, we receive your message, its attachments and your contact details in order to respond. If you attach a Port-Sight support archive (made in the Software or with `./maintenance.sh collect-logs`), it contains diagnostic information about your installation: software versions, health figures, settings with every password, key, token and SNMP credential removed, recent poll results and switch status with switch names replaced by placeholders, flow collector and scheduler state, application logs with secrets removed, and facts about the host server (operating system, network interfaces and routes, clock and time-sync state) with IP addresses replaced by placeholders. An archive is only ever sent when you choose to send it. We use it only to diagnose the problem you reported.

**d. Automated support assistance.** Mail to support@port-sight.com, including its attachments, is read by an automated assistant that we operate. It prepares a draft reply, which a person at KABIN Labs reviews before anything is sent to you. To do this, the content of your message and the diagnostic findings from any attached archive are sent to our AI model provider (Anthropic) under our account. We do not use your messages to train AI models, and our provider's commercial terms do not permit it to train on them.

**e. Website information.** If you visit `port-sight.com`, our hosting providers may log standard technical information (such as IP address and browser type) for security and operation.

## 2. Information we do NOT collect

Because the Software is self-hosted, we do **not** collect or have access to the following, except for the diagnostic information in a support archive you choose to send us (section 1c): your network topology or traffic, device inventories, switch/interface data, SNMP data or credentials, configuration, or how you use the Software. SNMP and device credentials you enter into the Software are stored encrypted **within your own installation** and are never transmitted to us, including in support archives.

The Software's optional in-app assistant sends questions and the data needed to answer them to the AI model provider **you** configure, under **your** account and key. That data goes directly from your installation to your provider; it does not pass through us.

## 3. How we use information

We use the information above to: issue, validate, renew, and revoke licenses; process payments and prevent fraud; provide support; send transactional messages (e.g., activation codes, renewal notices); and comply with legal and tax obligations.

## 4. How we share information

We do not sell personal information. We share it only with service providers that help us run the Services, under contractual confidentiality obligations:

- **Stripe**: payment processing and billing.
- **Resend**: delivery of transactional emails (e.g., activation codes, renewals).
- **Fastmail**: hosting of the support mailbox (support@port-sight.com), including the messages and attachments you send to it.
- **Anthropic**: the AI model that drafts support replies, receiving the content of support messages and the findings from attached support archives (section 1d).
- **Render, Neon, and Backblaze**: hosting, database, and encrypted backups for the licensing service; Render also hosts the automated support assistant.

We may also disclose information if required by law or to protect our rights.

## 5. Data retention

We retain purchase, license, and audit records for as long as needed to provide the Services and to meet legal, accounting, and tax requirements, after which we delete or anonymize them. Support messages and their attachments are kept in the support mailbox for as long as needed to resolve the request and keep a record of it; you can ask us to delete them at any time.

## 6. Security

We protect information using industry-standard measures, including encryption in transit (HTTPS) and encryption at rest for credentials and backups. No method of transmission or storage is completely secure, and we cannot guarantee absolute security.

## 7. Your rights

Depending on where you live, you may have rights to access, correct, delete, or port your personal information, or to object to certain processing. To exercise these rights, contact us at support@port-sight.com. We will respond as required by applicable law.

## 8. International users

We are based in the United States, and the limited information we collect is processed and stored in the United States. By using the Services, you understand your information may be processed in the U.S.

## 9. Children

The Services are not directed to children under 16, and we do not knowingly collect personal information from them.

## 10. Changes to this policy

We may update this Privacy Policy from time to time. We will post the updated version at `https://port-sight.com` with a revised effective date.

## 11. Contact

KABIN Labs LLC
3 Atherton Garth, Lutherville Timonium, MD 21093, USA
support@port-sight.com
