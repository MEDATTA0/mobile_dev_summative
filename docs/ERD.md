# EmpowerHER ERP Entity Relationship Diagram

Firestore is document-based, so each "entity" below is a top-level collection.
Primary keys are Firestore document IDs; foreign keys are stored as string ID
fields. `users` documents are keyed by the Firebase Auth `uid`.

## Diagram

```mermaid
erDiagram
    USERS ||--o{ ENROLLMENTS : "enrolls in"
    PROJECTS ||--o{ ENROLLMENTS : "has"
    USERS ||--o{ COMMUNITY_POSTS : "writes"
    COMMUNITY_POSTS ||--o{ REPLIES : "receives"
    USERS ||--o{ REPLIES : "writes"
    USERS ||--o{ JOB_APPLICATIONS : "submits"
    JOB_POSTINGS ||--o{ JOB_APPLICATIONS : "receives"

    USERS {
        string uid PK
        string name
        string email
        string headline
        string bio
        string location
        string phone
        string photoUrl
        array  skills
        datetime createdAt
        datetime updatedAt
    }

    PROJECTS {
        string id PK
        string title
        string subtitle
        string description
        string level
        array  objectives
        array  steps
        datetime createdAt
        datetime updatedAt
    }

    ENROLLMENTS {
        string id PK
        string projectId FK
        string userId FK
        string projectTitle
        string status
        int    completedSteps
        int    totalSteps
        string submissionUrl
        datetime enrolledAt
        datetime createdAt
        datetime updatedAt
    }

    COMMUNITY_POSTS {
        string id PK
        string authorId FK
        string authorName
        string title
        string body
        string tag
        datetime createdAt
        datetime updatedAt
    }

    REPLIES {
        string id PK
        string postId FK
        string authorId FK
        string authorName
        string body
        datetime createdAt
        datetime updatedAt
    }

    JOB_POSTINGS {
        string id PK
        string title
        string company
        string employmentType
        string location
        string description
        datetime postedAt
        datetime createdAt
        datetime updatedAt
    }

    JOB_APPLICATIONS {
        string id PK
        string userId FK
        string jobPostingId FK
        string company
        string position
        string location
        string status
        string cvUrl
        string coverLetter
        datetime appliedDate
        datetime createdAt
        datetime updatedAt
    }
```

## Collections (entities)

| Collection | Purpose | Primary key | Foreign keys |
|---|---|---|---|
| `users` | Member profile (auth + profile fields) | `uid` (doc id) | — |
| `projects` | Learning project catalog (seeded) | `id` | — |
| `enrollments` | A user's enrollment/progress in a project | `id` | `userId` → users, `projectId` → projects |
| `community_posts` | Community questions/updates | `id` | `authorId` → users |
| `replies` | Replies on a community post | `id` | `postId` → community_posts, `authorId` → users |
| `job_postings` | Job listings catalog (seeded) | `id` | — |
| `jobs` (job applications) | A user's application to a posting | `id` | `userId` → users, `jobPostingId` → job_postings |

## Relationships

- **User – Project (many-to-many)** resolved through **`enrollments`**: a user
  enrolls in many projects; a project has many enrolled users. Progress
  (`completedSteps` / `totalSteps`, `status`, `submissionUrl`) lives on the
  enrollment.
- **User → Community posts (1-to-many)**: a user authors many posts
  (`authorId`).
- **Community post → Replies (1-to-many)**: a post receives many replies
  (`postId`); each reply is also authored by a user (`authorId`).
- **User – Job posting (many-to-many)** resolved through **`jobs`** (job
  applications): a user applies to many postings; a posting receives many
  applications. Application state (`status`, `cvUrl`, `coverLetter`) lives on
  the application.

## Ownership (drives the Firestore security rules)

| Collection | Owner field | Write access |
|---|---|---|
| `users` | document id (`uid`) | owner only |
| `community_posts` | `authorId` | author only |
| `replies` | `authorId` | author only |
| `jobs` | `userId` | applicant only |
| `enrollments` | `userId` | enrolled user only |
| `projects`, `job_postings` | — (catalog) | read-only for signed-in users |
