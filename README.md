# Relay

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-000000?style=for-the-badge&logo=swift&logoColor=blue)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

## About The Project

Relay modernizes career fairs by acting as a "Hinge for Recruiters." It replaces paper resumes with digital profiles and long physical lines with instant digital queues.

Recruiters create events, and candidates join via a 6-digit code. Recruiters then review applicants one by one using a rapid "swipe" interface (Interested/Pass), allowing for faster processing and immediate feedback.

## Key Features

**For Candidates**
* **Rich Profiles:** Showcase personality via prompts, skills, and resume links.
* **One-Tap Join:** Enter a 6-digit code to instantly join a digital queue.
* **Real-Time Notifications:** Receive instant updates when a recruiter extends an offer.

**For Recruiters**
* **Event Creation:** Generate unique access codes for career fairs.
* **Rapid Review:** A focused view of one candidate at a time to speed up screening.
* **Decision Dashboard:** Manage candidates marked as "Interested" and send formal offers.

## Technical Architectures

This project follows the **MVVM (Model-View-ViewModel)** architecture pattern.

* **Frontend:** SwiftUI (iOS)
* **Backend:** Google Firebase (Firestore Database & Authentication)
* **State Management:** `@EnvironmentObject` for global user state.
* **Real-Time Data:** Uses Firestore snapshot listeners to push updates (like offers) instantly without refreshing.

**Database Structure (NoSQL)**
* `users`: Login info & roles.
* `candidates` / `recruiters`: Profile details.
* `events`: Event locations & access codes.
* `eventAttendances`: Link table connecting Candidates to Events.
* `decisions`: Recruiter choices & private notes.

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Viiridiz/Relay.git
    ```
2.  **Open in Xcode:**
    Double-click `Relay.xcodeproj`.
3.  **Run:**
    Select your simulator and press **Cmd + R**.
