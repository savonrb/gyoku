# Security Policy

## Supported versions

Security fixes are released for the latest 1.x release.

| Version | Supported          |
| ------- | ------------------ |
| 1.4.x   | :white_check_mark: |
| < 1.4   | :x:                |

If you are on an older release, upgrade to the latest 1.x before reporting.

## Reporting a vulnerability

Please do not report security issues through public GitHub issues.

Instead, [report a vulnerability privately](https://github.com/savonrb/gyoku/security/advisories/new)
through GitHub. You will get an acknowledgement within 7 days. Please keep the
report confidential until a fix is released.

## Scope

This policy covers the gyoku gem, the request builder used by the savon SOAP
client to translate Ruby hashes into XML. For issues in another gem in the
family (akami, httpi, nori, savon, wasabi), report to the affected repository
in the [savonrb organization](https://github.com/savonrb). If you are not sure
which gem is affected, report it here.
