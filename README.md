# OWASP-10-A05-security-misconfiguration

## Server Security Misconfiguration Analysis with Nikto

This repository contains the findings and methodology used to analyze server security misconfigurations, primarily utilizing the Nikto web scanner. The aim was to explore the practical application of a vulnerability scanner in identifying potential weaknesses arising from improper server configurations.

## Introduction

Security misconfiguration is a broad topic in cybersecurity, encompassing a wide range of vulnerabilities that can arise from insecure default configurations, improper setup of services, or ad-hoc changes during deployment. Addressing these vulnerabilities is crucial for maintaining a secure application and server environment.

Our approach was guided by well-established security resources, including:

* OWASP Testing Guide: Configuration Management
* OWASP Testing Guide: Testing for Error Codes
* Application Security Verification Standard V14 Configuration
* NIST Guide to General Server Hardening
* CIS Security Configuration Guides/Benchmarks
* Amazon S3 Bucket Discovery and Enumeration

From these resources, we identified Nikto as a practical and effective tool for initial vulnerability scanning, particularly for its ability to identify common misconfigurations and its user-friendly interface.

## Why Nikto?

Nikto was chosen for several compelling reasons:

* **Automated Knowledge:** It automates the process of checking for well-known web directories and common vulnerabilities, saving significant manual effort.
* **Simple Entry Point:** It provides a straightforward and comprehensive way to begin addressing server security.
* **Free and Open Source:** Nikto is a readily available and cost-effective tool.
* **Offensive for Defensive Insight:** By understanding how an attacker might identify vulnerabilities, we can better craft defensive strategies.

## Nikto First Steps

### Installation

The installation process for Nikto is relatively straightforward, primarily involving Perl.

1.  Install Perl.
2.  Download and extract the Nikto repository content: `git clone https://github.com/sullo/nikto.git`
3.  Navigate to the `nikto-master/program` directory.
4.  Open a command prompt or terminal in this directory.
5.  Execute `perl nikto.pl`.

**Important Caveat:** During the installation, a common issue was encountered regarding Perl versions. While Strawberry and ActiveState Perl are common choices, the version bundled with Git Bash proved to be the most compatible and resolved connection issues. This issue is also documented [here](https://github.com/sullo/nikto/issues/472).

### Basic Execution

Initially, scanning the local host on standard web ports yielded no results, indicating no active web server on those ports.

```bash
perl nikto.pl -h 192.168.1.135
````

To gain more insight, increasing verbosity was crucial:

```bash
perl nikto.pl -h 192.168.1.135 -Display V
```

This revealed that no service was listening on port 80. Trying port 443 also yielded no results.

```bash
perl nikto.pl -h 192.168.1.135 -Display V -p 443
```

The breakthrough came when targeting the specific port of our running application and using `localhost`:

```bash
perl nikto.pl -h localhost -Display V -p 7103
```

### Generating Reports

To obtain a structured output of the scan results, using the `-o` (output) flag with a format is necessary. Always consult the CLI help (`perl nikto.pl -H` or `man nikto`) for the most accurate syntax.

```bash
# Incorrect attempt
perl nikto.pl -h localhost -Display V -p 7103 -Format HTML

# Corrected command for HTML output
perl nikto.pl -h localhost -Display V -p 7103 -o report.html
```

The final reports are available in the `reports/` directory of this repository.

## Executing Nikto Against WebGoat

To further test Nikto's capabilities and against a known vulnerable application, WebGoat (from OWASP) was used.

1.  Set the timezone environment variable:
    ```bash
    export TZ=Europe/Amsterdam # or your timezone
    ```
2.  Run the WebGoat application:
    ```bash
    java -Dfile.encoding=UTF-8 -jar webgoat-2025.3.jar
    ```
3.  Execute Nikto against WebGoat:
    ```bash
    perl nikto.pl -h [http://127.0.0.1:8080](http://127.0.0.1:8080) -Display V -o wg.html -S wg-results
    ```

While WebGoat did provide some additional findings, such as exploitable HTTP methods, the overall difference in the extent of reported vulnerabilities was not as remarkable as anticipated, possibly due to the nature of the application's exposed surface.

## Insights and Automation

Through these exercises, several key insights were gained:

  * **Understanding Mechanisms:** Interacting with the Nikto CLI by changing options, observing logs, and analyzing HTTP response codes provides a deeper understanding of how vulnerability scanners operate.
  * **Targeting Servers vs. Endpoints:** It became clear that Nikto primarily targets the server itself and its common web directories, rather than specific REST API endpoints. The root URL (IP/hostname and port) is the critical target for this type of scanner.
  * **Leveraging CLI Options:** The `evasion` and `mutate` switches are particularly useful for dynamic encoding techniques and guessing additional files, respectively, enhancing the scanning process.

To streamline the execution of various Nikto scans with different options, a bash script has been included in this repository (`run_scans.sh`). This script automates multiple executions as an example of how to efficiently test different configurations and features of Nikto.

## Further Exploration

While this project focused on Nikto, the initial research unveiled several other highly valuable resources for server hardening and security configuration:

  * **NIST Guidelines:** An extensive theoretical resource offering thorough explanations and detailed information for achieving commonly agreed-upon server hardening measures.
  * **CIS Security Configuration Guides/Benchmarks:** An impressive collection of prescriptive configuration recommendations for a wide array of vendor products, providing painstaking levels of detail for different categories like network devices, server software, and operating systems.
  * **OWASP Application Security Verification Standard (ASVS) v14:** Relevant for its emphasis on integrating security checks throughout the entire software development lifecycle.
  * **OWASP Testing Guide: Testing for Error Codes:** A crucial guide specifically addressing error handling, a well-known security vulnerability, and providing actionable insights and additional resources like the error handling cheat sheet.
  * **OWASP Configuration and Deployment Management Testing:** This resource addresses a range of issues, offering ad-hoc descriptions and solutions for concerns like file extensions, network configuration, application platform settings, backups, and path confusion.
