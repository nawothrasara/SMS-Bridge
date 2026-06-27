# SMS Bridge

**SMS Bridge** is a lightweight, reliable Flutter application designed to bridge the gap between physical mobile devices and web applications. It monitors incoming SMS notifications in real-time, filters them based on user-defined sender masks, and instantly forwards the payload to a configured web server or database. 

This application is ideal for entrepreneurs, e-commerce platforms, and digital service providers who need to automate workflows—such as instant service provisioning upon receiving mobile money (e.g., eZ Cash) or bank transaction SMS alerts—without manual verification.

---

## 🚀 Features

* **Real-Time SMS Monitoring:** Continuously listens for incoming SMS messages on the device.
* **Smart Mask Filtering:** Only intercepts and processes messages originating from specified sender IDs or numbers.
* **Automated Webhook Forwarding:** Automatically pushes message data to your backend API as soon as it arrives.
* **Manual Entry Dashboard:** A backup interface to manually input and push custom text or missed messages directly to your database.
* **Local Transaction Logging:** Includes a transaction counter and status dashboard tracking total vs. pending logs.

---

## 📱 User Interface

The application features a clean, intuitive, and modern UI built with Flutter:

| Dashboard View | Settings Configuration |
| --- | --- |
|  featuring the messaging counter, manual entry box, and transaction logs. |  showcasing the API Gateway, API Key fields, and sender mask rules. |

---

## 🛠️ Configuration & Setup

### 1. API Configuration
Navigate to the **Settings** menu to establish connection rules:
* **Base URL:** The target HTTP endpoint where data payloads will be forwarded.
* **API Key:** Secure authentication token bundled into the request header for server-side validation.

### 2. SMS Rules
* **Sender Masks / Numbers:** Input specific strings or numbers (e.g., `eZCash, BANK_ALERT, +12345678`). You can separate multiple identities using a comma (`,`).

---

## 🔄 Technical Workflow

1. **Listen:** The background service monitors incoming SMS streams.
2. **Filter:** The application verifies if the sender matches any configured mask string.
3. **Dispatch:** On match success, a structured JSON payload is transmitted via an HTTP POST request to your backend:

```json
{
  "sender": "eZCash",
  "message": "You have received RS 5000.00 from...",
  "timestamp": "2026-06-26T00:02:25Z"
}
