;; restorative-justice-mediation
;; Digital platform facilitating community-based conflict resolution processes
;; This contract manages mediation cases, participants, sessions, and outcomes
;; in a transparent and auditable manner using blockchain technology.

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-STATUS (err u103))
(define-constant ERR-CASE-CLOSED (err u104))
(define-constant ERR-INSUFFICIENT-PARTICIPANTS (err u105))
(define-constant ERR-INVALID-PARTICIPANT (err u106))
(define-constant ERR-SESSION-NOT-READY (err u107))

;; Status constants
(define-constant STATUS-REGISTERED u1)
(define-constant STATUS-PARTICIPANTS-CONFIRMED u2)
(define-constant STATUS-MEDIATION-SCHEDULED u3)
(define-constant STATUS-IN-PROGRESS u4)
(define-constant STATUS-COMPLETED u5)
(define-constant STATUS-CANCELLED u6)

;; Participant role constants
(define-constant ROLE-VICTIM u1)
(define-constant ROLE-OFFENDER u2)
(define-constant ROLE-MEDIATOR u3)
(define-constant ROLE-COMMUNITY-MEMBER u4)
(define-constant ROLE-ADVOCATE u5)

;; Agreement status constants
(define-constant AGREEMENT-PENDING u1)
(define-constant AGREEMENT-ACCEPTED u2)
(define-constant AGREEMENT-REJECTED u3)

;; Data variables
(define-data-var case-counter uint u0)
(define-data-var session-counter uint u0)
(define-data-var contract-admin principal tx-sender)

;; Data maps for case management
(define-map mediation-cases
  uint
  {
    victim: principal,
    offender: principal,
    mediator: (optional principal),
    case-description: (string-ascii 500),
    status: uint,
    created-at: uint,
    updated-at: uint,
    priority-level: uint,
    case-type: (string-ascii 100),
    location: (string-ascii 200)
  }
)

;; Participant registration and management
(define-map case-participants
  { case-id: uint, participant: principal }
  {
    role: uint,
    confirmed: bool,
    joined-at: uint,
    contact-info: (string-ascii 200),
    special-needs: (string-ascii 300)
  }
)

;; Session scheduling and tracking
(define-map mediation-sessions
  uint
  {
    case-id: uint,
    session-date: uint,
    session-duration: uint,
    session-type: (string-ascii 50),
    location: (string-ascii 200),
    status: uint,
    notes: (string-ascii 1000),
    created-by: principal
  }
)

;; Session attendance tracking
(define-map session-attendance
  { session-id: uint, participant: principal }
  {
    attended: bool,
    arrival-time: (optional uint),
    departure-time: (optional uint),
    participation-quality: uint
  }
)

;; Mediation outcomes and agreements
(define-map case-outcomes
  uint
  {
    case-id: uint,
    outcome-type: (string-ascii 100),
    agreement-reached: bool,
    agreement-details: (string-ascii 1000),
    next-steps: (string-ascii 500),
    follow-up-required: bool,
    follow-up-date: (optional uint),
    victim-satisfaction: uint,
    offender-commitment: uint,
    community-impact: (string-ascii 300)
  }
)

;; Agreement tracking for accountability
(define-map participant-agreements
  { case-id: uint, participant: principal }
  {
    agreement-status: uint,
    signed-at: (optional uint),
    commitments: (string-ascii 500),
    completion-deadline: (optional uint),
    progress-updates: (string-ascii 800)
  }
)

;; Community involvement tracking
(define-map community-involvement
  uint
  {
    case-id: uint,
    community-members: uint,
    community-feedback: (string-ascii 800),
    healing-activities: (string-ascii 500),
    resource-commitments: (string-ascii 400)
  }
)

;; Mediator qualifications and availability
(define-map certified-mediators
  principal
  {
    certification-level: uint,
    specializations: (string-ascii 300),
    active-cases: uint,
    availability-status: bool,
    experience-years: uint,
    success-rate: uint
  }
)

;; Private helper functions
(define-private (is-admin (caller principal))
  (is-eq caller (var-get contract-admin))
)

(define-private (is-case-participant (case-id uint) (participant principal))
  (is-some (map-get? case-participants { case-id: case-id, participant: participant }))
)

(define-private (is-valid-status (status uint))
  (and (>= status u1) (<= status u6))
)

(define-private (is-valid-role (role uint))
  (and (>= role u1) (<= role u5))
)

(define-private (get-current-time)
  stacks-block-height
)

;; Public functions for case management

;; Register a new mediation case
(define-public (register-case 
    (victim principal)
    (offender principal)
    (case-description (string-ascii 500))
    (priority-level uint)
    (case-type (string-ascii 100))
    (location (string-ascii 200))
  )
  (let (
    (new-case-id (+ (var-get case-counter) u1))
    (current-time (get-current-time))
  )
    (begin
      (asserts! (not (is-eq victim offender)) ERR-INVALID-PARTICIPANT)
      (asserts! (and (>= priority-level u1) (<= priority-level u5)) ERR-INVALID-STATUS)
      
      (map-set mediation-cases new-case-id {
        victim: victim,
        offender: offender,
        mediator: none,
        case-description: case-description,
        status: STATUS-REGISTERED,
        created-at: current-time,
        updated-at: current-time,
        priority-level: priority-level,
        case-type: case-type,
        location: location
      })
      
      ;; Register victim and offender as participants
      (map-set case-participants { case-id: new-case-id, participant: victim } {
        role: ROLE-VICTIM,
        confirmed: false,
        joined-at: current-time,
        contact-info: "",
        special-needs: ""
      })
      
      (map-set case-participants { case-id: new-case-id, participant: offender } {
        role: ROLE-OFFENDER,
        confirmed: false,
        joined-at: current-time,
        contact-info: "",
        special-needs: ""
      })
      
      (var-set case-counter new-case-id)
      (ok new-case-id)
    )
  )
)

;; Add participant to case
(define-public (add-participant
    (case-id uint)
    (participant principal)
    (role uint)
    (contact-info (string-ascii 200))
    (special-needs (string-ascii 300))
  )
  (let (
    (case-data (unwrap! (map-get? mediation-cases case-id) ERR-NOT-FOUND))
  )
    (begin
      (asserts! (is-valid-role role) ERR-INVALID-PARTICIPANT)
      (asserts! (not (is-case-participant case-id participant)) ERR-ALREADY-EXISTS)
      (asserts! (<= (get status case-data) STATUS-PARTICIPANTS-CONFIRMED) ERR-CASE-CLOSED)
      
      (map-set case-participants { case-id: case-id, participant: participant } {
        role: role,
        confirmed: false,
        joined-at: (get-current-time),
        contact-info: contact-info,
        special-needs: special-needs
      })
      
      (ok true)
    )
  )
)

;; Confirm participation in case
(define-public (confirm-participation (case-id uint))
  (let (
    (participant-data (unwrap! (map-get? case-participants { case-id: case-id, participant: tx-sender }) ERR-NOT-FOUND))
  )
    (begin
      (map-set case-participants { case-id: case-id, participant: tx-sender }
        (merge participant-data { confirmed: true })
      )
      (ok true)
    )
  )
)

;; Assign mediator to case
(define-public (assign-mediator (case-id uint) (mediator principal))
  (let (
    (case-data (unwrap! (map-get? mediation-cases case-id) ERR-NOT-FOUND))
    (mediator-data (unwrap! (map-get? certified-mediators mediator) ERR-INVALID-PARTICIPANT))
  )
    (begin
      (asserts! (get availability-status mediator-data) ERR-INVALID-PARTICIPANT)
      (asserts! (is-eq (get status case-data) STATUS-PARTICIPANTS-CONFIRMED) ERR-INVALID-STATUS)
      
      (map-set mediation-cases case-id
        (merge case-data {
          mediator: (some mediator),
          status: STATUS-MEDIATION-SCHEDULED,
          updated-at: (get-current-time)
        })
      )
      
      ;; Add mediator as participant
      (map-set case-participants { case-id: case-id, participant: mediator } {
        role: ROLE-MEDIATOR,
        confirmed: true,
        joined-at: (get-current-time),
        contact-info: "",
        special-needs: ""
      })
      
      (ok true)
    )
  )
)

;; Schedule mediation session
(define-public (schedule-session
    (case-id uint)
    (session-date uint)
    (session-duration uint)
    (session-type (string-ascii 50))
    (location (string-ascii 200))
  )
  (let (
    (new-session-id (+ (var-get session-counter) u1))
    (case-data (unwrap! (map-get? mediation-cases case-id) ERR-NOT-FOUND))
  )
    (begin
      (asserts! (is-some (get mediator case-data)) ERR-SESSION-NOT-READY)
      (asserts! (>= session-date (get-current-time)) ERR-INVALID-STATUS)
      
      (map-set mediation-sessions new-session-id {
        case-id: case-id,
        session-date: session-date,
        session-duration: session-duration,
        session-type: session-type,
        location: location,
        status: STATUS-REGISTERED,
        notes: "",
        created-by: tx-sender
      })
      
      (var-set session-counter new-session-id)
      (ok new-session-id)
    )
  )
)

;; Record session attendance
(define-public (record-attendance
    (session-id uint)
    (participant principal)
    (attended bool)
    (arrival-time (optional uint))
    (participation-quality uint)
  )
  (let (
    (session-data (unwrap! (map-get? mediation-sessions session-id) ERR-NOT-FOUND))
    (case-id (get case-id session-data))
  )
    (begin
      (asserts! (is-case-participant case-id participant) ERR-INVALID-PARTICIPANT)
      (asserts! (and (>= participation-quality u1) (<= participation-quality u5)) ERR-INVALID-STATUS)
      
      (map-set session-attendance { session-id: session-id, participant: participant } {
        attended: attended,
        arrival-time: arrival-time,
        departure-time: none,
        participation-quality: participation-quality
      })
      
      (ok true)
    )
  )
)

;; Record case outcome
(define-public (record-outcome
    (case-id uint)
    (outcome-type (string-ascii 100))
    (agreement-reached bool)
    (agreement-details (string-ascii 1000))
    (next-steps (string-ascii 500))
    (follow-up-required bool)
    (follow-up-date (optional uint))
    (victim-satisfaction uint)
    (offender-commitment uint)
    (community-impact (string-ascii 300))
  )
  (let (
    (case-data (unwrap! (map-get? mediation-cases case-id) ERR-NOT-FOUND))
    (outcome-id (+ case-id u1000000)) ;; Simple outcome ID generation
  )
    (begin
      (asserts! (is-case-participant case-id tx-sender) ERR-UNAUTHORIZED)
      (asserts! (is-eq (get status case-data) STATUS-IN-PROGRESS) ERR-INVALID-STATUS)
      (asserts! (and (>= victim-satisfaction u1) (<= victim-satisfaction u5)) ERR-INVALID-STATUS)
      (asserts! (and (>= offender-commitment u1) (<= offender-commitment u5)) ERR-INVALID-STATUS)
      
      (map-set case-outcomes outcome-id {
        case-id: case-id,
        outcome-type: outcome-type,
        agreement-reached: agreement-reached,
        agreement-details: agreement-details,
        next-steps: next-steps,
        follow-up-required: follow-up-required,
        follow-up-date: follow-up-date,
        victim-satisfaction: victim-satisfaction,
        offender-commitment: offender-commitment,
        community-impact: community-impact
      })
      
      ;; Update case status to completed
      (map-set mediation-cases case-id
        (merge case-data {
          status: STATUS-COMPLETED,
          updated-at: (get-current-time)
        })
      )
      
      (ok outcome-id)
    )
  )
)

;; Read-only functions for data access
(define-read-only (get-case (case-id uint))
  (map-get? mediation-cases case-id)
)

(define-read-only (get-participant (case-id uint) (participant principal))
  (map-get? case-participants { case-id: case-id, participant: participant })
)

(define-read-only (get-session (session-id uint))
  (map-get? mediation-sessions session-id)
)

(define-read-only (get-outcome (outcome-id uint))
  (map-get? case-outcomes outcome-id)
)

(define-read-only (get-case-count)
  (var-get case-counter)
)

(define-read-only (is-mediator-certified (mediator principal))
  (is-some (map-get? certified-mediators mediator))
)
