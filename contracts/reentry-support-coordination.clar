;; reentry-support-coordination
;; Comprehensive support system for formerly incarcerated individuals
;; This contract manages individual cases, resource allocation, service coordination,
;; and progress tracking for successful community reintegration.

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u200))
(define-constant ERR-NOT-FOUND (err u201))
(define-constant ERR-ALREADY-EXISTS (err u202))
(define-constant ERR-INVALID-STATUS (err u203))
(define-constant ERR-INVALID-ROLE (err u204))
(define-constant ERR-INSUFFICIENT-RESOURCES (err u205))
(define-constant ERR-INVALID-PARTICIPANT (err u206))
(define-constant ERR-CASE-COMPLETED (err u207))
(define-constant ERR-INVALID-TIMEFRAME (err u208))

;; Status constants for case management
(define-constant STATUS-INTAKE u1)
(define-constant STATUS-ASSESSMENT-COMPLETE u2)
(define-constant STATUS-PLAN-CREATED u3)
(define-constant STATUS-SERVICES-ACTIVE u4)
(define-constant STATUS-TRANSITION-PHASE u5)
(define-constant STATUS-INDEPENDENT u6)
(define-constant STATUS-CASE-CLOSED u7)

;; Service category constants
(define-constant SERVICE-HOUSING u1)
(define-constant SERVICE-EMPLOYMENT u2)
(define-constant SERVICE-EDUCATION u3)
(define-constant SERVICE-HEALTHCARE u4)
(define-constant SERVICE-MENTAL-HEALTH u5)
(define-constant SERVICE-SUBSTANCE-ABUSE u6)
(define-constant SERVICE-LEGAL-AID u7)
(define-constant SERVICE-TRANSPORTATION u8)
(define-constant SERVICE-MENTORSHIP u9)
(define-constant SERVICE-FAMILY-REUNIFICATION u10)

;; Priority levels
(define-constant PRIORITY-CRITICAL u1)
(define-constant PRIORITY-HIGH u2)
(define-constant PRIORITY-MEDIUM u3)
(define-constant PRIORITY-LOW u4)

;; Progress status
(define-constant PROGRESS-NOT-STARTED u1)
(define-constant PROGRESS-IN-PROGRESS u2)
(define-constant PROGRESS-COMPLETED u3)
(define-constant PROGRESS-ON-HOLD u4)
(define-constant PROGRESS-CANCELLED u5)

;; Data variables
(define-data-var case-counter uint u0)
(define-data-var service-counter uint u0)
(define-data-var resource-counter uint u0)
(define-data-var contract-admin principal tx-sender)

;; Individual case management
(define-map reentry-cases
  uint
  {
    participant: principal,
    case-manager: principal,
    intake-date: uint,
    release-date: uint,
    case-status: uint,
    risk-assessment-score: uint,
    priority-level: uint,
    expected-completion: uint,
    case-notes: (string-ascii 1000),
    last-updated: uint,
    emergency-contact: (string-ascii 200),
    location: (string-ascii 200)
  }
)

;; Individual assessment and needs analysis
(define-map participant-assessments
  uint
  {
    case-id: uint,
    housing-status: uint,
    employment-status: uint,
    education-level: uint,
    health-needs: (string-ascii 500),
    mental-health-needs: (string-ascii 500),
    substance-abuse-history: bool,
    family-support-available: bool,
    criminal-history-summary: (string-ascii 300),
    special-accommodations: (string-ascii 400),
    assessment-date: uint,
    assessor: principal
  }
)

;; Service provision tracking
(define-map service-assignments
  uint
  {
    case-id: uint,
    service-type: uint,
    provider-organization: (string-ascii 200),
    service-description: (string-ascii 500),
    start-date: uint,
    expected-end-date: uint,
    actual-end-date: (optional uint),
    service-status: uint,
    cost-allocation: uint,
    provider-contact: (string-ascii 200),
    service-location: (string-ascii 200),
    frequency: (string-ascii 100)
  }
)

;; Resource allocation and budget tracking
(define-map resource-allocations
  uint
  {
    case-id: uint,
    resource-type: uint,
    allocated-amount: uint,
    spent-amount: uint,
    remaining-balance: uint,
    allocation-date: uint,
    expiration-date: uint,
    funding-source: (string-ascii 200),
    approval-required: bool,
    approved-by: (optional principal)
  }
)

;; Progress tracking and milestones
(define-map case-milestones
  uint
  {
    case-id: uint,
    milestone-description: (string-ascii 300),
    target-date: uint,
    completion-date: (optional uint),
    milestone-status: uint,
    verification-method: (string-ascii 200),
    verified-by: (optional principal),
    milestone-notes: (string-ascii 500),
    importance-level: uint
  }
)

;; Employment assistance and job placement
(define-map employment-services
  uint
  {
    case-id: uint,
    job-search-status: uint,
    resume-completed: bool,
    skills-training-needed: (string-ascii 400),
    certifications-pursued: (string-ascii 300),
    job-placement-date: (optional uint),
    employer-name: (string-ascii 200),
    job-title: (string-ascii 100),
    hourly-wage: (optional uint),
    employment-support-needed: bool,
    job-coach-assigned: (optional principal)
  }
)

;; Housing assistance tracking
(define-map housing-services
  uint
  {
    case-id: uint,
    current-housing-type: (string-ascii 100),
    housing-stability-score: uint,
    transitional-housing-needed: bool,
    permanent-housing-secured: bool,
    housing-voucher-status: uint,
    rental-assistance-amount: uint,
    housing-search-assistance: bool,
    housing-placement-date: (optional uint),
    housing-address: (string-ascii 300),
    landlord-contact: (string-ascii 200)
  }
)

;; Community mentorship matching
(define-map mentorship-assignments
  uint
  {
    case-id: uint,
    mentor-principal: principal,
    mentorship-start-date: uint,
    mentorship-type: (string-ascii 100),
    meeting-frequency: (string-ascii 50),
    mentor-background: (string-ascii 300),
    mentorship-goals: (string-ascii 500),
    mentorship-status: uint,
    last-contact-date: uint,
    mentor-satisfaction: uint,
    mentee-satisfaction: uint
  }
)

;; Certified service providers and case managers
(define-map certified-providers
  principal
  {
    provider-name: (string-ascii 200),
    certification-level: uint,
    service-specializations: (string-ascii 400),
    active-cases: uint,
    max-case-load: uint,
    availability-status: bool,
    years-experience: uint,
    success-rate: uint,
    contact-information: (string-ascii 300)
  }
)

;; Resource inventory management
(define-map available-resources
  uint
  {
    resource-name: (string-ascii 200),
    resource-type: uint,
    total-available: uint,
    currently-allocated: uint,
    cost-per-unit: uint,
    funding-source: (string-ascii 200),
    availability-window: (string-ascii 100),
    geographic-restrictions: (string-ascii 200),
    eligibility-criteria: (string-ascii 500)
  }
)

;; Private helper functions
(define-private (is-admin (caller principal))
  (is-eq caller (var-get contract-admin))
)

(define-private (is-case-manager (case-id uint) (caller principal))
  (match (map-get? reentry-cases case-id)
    case-data (is-eq caller (get case-manager case-data))
    false
  )
)

(define-private (is-valid-status (status uint))
  (and (>= status u1) (<= status u7))
)

(define-private (is-valid-service-type (service-type uint))
  (and (>= service-type u1) (<= service-type u10))
)

(define-private (get-current-time)
  stacks-block-height
)

(define-private (calculate-days-difference (start-date uint) (end-date uint))
  (if (>= end-date start-date)
    (- end-date start-date)
    u0
  )
)

;; Public functions for case management

;; Create new reentry case
(define-public (create-reentry-case
    (participant principal)
    (case-manager principal)
    (release-date uint)
    (risk-assessment-score uint)
    (priority-level uint)
    (expected-completion uint)
    (emergency-contact (string-ascii 200))
    (location (string-ascii 200))
  )
  (let (
    (new-case-id (+ (var-get case-counter) u1))
    (current-time (get-current-time))
  )
    (begin
      (asserts! (not (is-eq participant case-manager)) ERR-INVALID-PARTICIPANT)
      (asserts! (and (>= priority-level u1) (<= priority-level u4)) ERR-INVALID-STATUS)
      (asserts! (and (>= risk-assessment-score u1) (<= risk-assessment-score u10)) ERR-INVALID-STATUS)
      (asserts! (>= expected-completion current-time) ERR-INVALID-TIMEFRAME)
      
      (map-set reentry-cases new-case-id {
        participant: participant,
        case-manager: case-manager,
        intake-date: current-time,
        release-date: release-date,
        case-status: STATUS-INTAKE,
        risk-assessment-score: risk-assessment-score,
        priority-level: priority-level,
        expected-completion: expected-completion,
        case-notes: "",
        last-updated: current-time,
        emergency-contact: emergency-contact,
        location: location
      })
      
      (var-set case-counter new-case-id)
      (ok new-case-id)
    )
  )
)

;; Complete participant assessment
(define-public (complete-assessment
    (case-id uint)
    (housing-status uint)
    (employment-status uint)
    (education-level uint)
    (health-needs (string-ascii 500))
    (mental-health-needs (string-ascii 500))
    (substance-abuse-history bool)
    (family-support-available bool)
    (criminal-history-summary (string-ascii 300))
    (special-accommodations (string-ascii 400))
  )
  (let (
    (case-data (unwrap! (map-get? reentry-cases case-id) ERR-NOT-FOUND))
    (assessment-id (+ case-id u10000))
  )
    (begin
      (asserts! (is-case-manager case-id tx-sender) ERR-UNAUTHORIZED)
      (asserts! (is-eq (get case-status case-data) STATUS-INTAKE) ERR-INVALID-STATUS)
      
      (map-set participant-assessments assessment-id {
        case-id: case-id,
        housing-status: housing-status,
        employment-status: employment-status,
        education-level: education-level,
        health-needs: health-needs,
        mental-health-needs: mental-health-needs,
        substance-abuse-history: substance-abuse-history,
        family-support-available: family-support-available,
        criminal-history-summary: criminal-history-summary,
        special-accommodations: special-accommodations,
        assessment-date: (get-current-time),
        assessor: tx-sender
      })
      
      ;; Update case status
      (map-set reentry-cases case-id
        (merge case-data {
          case-status: STATUS-ASSESSMENT-COMPLETE,
          last-updated: (get-current-time)
        })
      )
      
      (ok assessment-id)
    )
  )
)

;; Assign service to participant
(define-public (assign-service
    (case-id uint)
    (service-type uint)
    (provider-organization (string-ascii 200))
    (service-description (string-ascii 500))
    (expected-duration-days uint)
    (cost-allocation uint)
    (provider-contact (string-ascii 200))
    (service-location (string-ascii 200))
    (frequency (string-ascii 100))
  )
  (let (
    (new-service-id (+ (var-get service-counter) u1))
    (case-data (unwrap! (map-get? reentry-cases case-id) ERR-NOT-FOUND))
    (current-time (get-current-time))
    (expected-end-date (+ current-time expected-duration-days))
  )
    (begin
      (asserts! (is-case-manager case-id tx-sender) ERR-UNAUTHORIZED)
      (asserts! (is-valid-service-type service-type) ERR-INVALID-STATUS)
      (asserts! (>= (get case-status case-data) STATUS-ASSESSMENT-COMPLETE) ERR-INVALID-STATUS)
      
      (map-set service-assignments new-service-id {
        case-id: case-id,
        service-type: service-type,
        provider-organization: provider-organization,
        service-description: service-description,
        start-date: current-time,
        expected-end-date: expected-end-date,
        actual-end-date: none,
        service-status: PROGRESS-NOT-STARTED,
        cost-allocation: cost-allocation,
        provider-contact: provider-contact,
        service-location: service-location,
        frequency: frequency
      })
      
      (var-set service-counter new-service-id)
      (ok new-service-id)
    )
  )
)

;; Allocate resources to case
(define-public (allocate-resource
    (case-id uint)
    (resource-type uint)
    (allocated-amount uint)
    (funding-source (string-ascii 200))
    (duration-days uint)
    (approval-required bool)
  )
  (let (
    (new-resource-id (+ (var-get resource-counter) u1))
    (case-data (unwrap! (map-get? reentry-cases case-id) ERR-NOT-FOUND))
    (current-time (get-current-time))
    (expiration-date (+ current-time duration-days))
  )
    (begin
      (asserts! (is-case-manager case-id tx-sender) ERR-UNAUTHORIZED)
      (asserts! (> allocated-amount u0) ERR-INSUFFICIENT-RESOURCES)
      
      (map-set resource-allocations new-resource-id {
        case-id: case-id,
        resource-type: resource-type,
        allocated-amount: allocated-amount,
        spent-amount: u0,
        remaining-balance: allocated-amount,
        allocation-date: current-time,
        expiration-date: expiration-date,
        funding-source: funding-source,
        approval-required: approval-required,
        approved-by: (if approval-required none (some tx-sender))
      })
      
      (var-set resource-counter new-resource-id)
      (ok new-resource-id)
    )
  )
)

;; Update service progress
(define-public (update-service-progress
    (service-id uint)
    (new-status uint)
    (completion-notes (string-ascii 500))
  )
  (let (
    (service-data (unwrap! (map-get? service-assignments service-id) ERR-NOT-FOUND))
    (case-id (get case-id service-data))
  )
    (begin
      (asserts! (is-case-manager case-id tx-sender) ERR-UNAUTHORIZED)
      (asserts! (and (>= new-status u1) (<= new-status u5)) ERR-INVALID-STATUS)
      
      (map-set service-assignments service-id
        (merge service-data {
          service-status: new-status,
          actual-end-date: (if (is-eq new-status PROGRESS-COMPLETED)
                             (some (get-current-time))
                             none)
        })
      )
      
      (ok true)
    )
  )
)

;; Record case milestone achievement
(define-public (record-milestone
    (case-id uint)
    (milestone-description (string-ascii 300))
    (target-date uint)
    (verification-method (string-ascii 200))
    (importance-level uint)
    (milestone-notes (string-ascii 500))
  )
  (let (
    (milestone-id (+ case-id (* importance-level u1000)))
    (case-data (unwrap! (map-get? reentry-cases case-id) ERR-NOT-FOUND))
  )
    (begin
      (asserts! (is-case-manager case-id tx-sender) ERR-UNAUTHORIZED)
      (asserts! (and (>= importance-level u1) (<= importance-level u5)) ERR-INVALID-STATUS)
      
      (map-set case-milestones milestone-id {
        case-id: case-id,
        milestone-description: milestone-description,
        target-date: target-date,
        completion-date: none,
        milestone-status: PROGRESS-NOT-STARTED,
        verification-method: verification-method,
        verified-by: none,
        milestone-notes: milestone-notes,
        importance-level: importance-level
      })
      
      (ok milestone-id)
    )
  )
)

;; Update case status
(define-public (update-case-status
    (case-id uint)
    (new-status uint)
    (update-notes (string-ascii 500))
  )
  (let (
    (case-data (unwrap! (map-get? reentry-cases case-id) ERR-NOT-FOUND))
  )
    (begin
      (asserts! (is-case-manager case-id tx-sender) ERR-UNAUTHORIZED)
      (asserts! (is-valid-status new-status) ERR-INVALID-STATUS)
      
      (map-set reentry-cases case-id
        (merge case-data {
          case-status: new-status,
          case-notes: update-notes,
          last-updated: (get-current-time)
        })
      )
      
      (ok true)
    )
  )
)

;; Read-only functions for data access
(define-read-only (get-case (case-id uint))
  (map-get? reentry-cases case-id)
)

(define-read-only (get-assessment (assessment-id uint))
  (map-get? participant-assessments assessment-id)
)

(define-read-only (get-service (service-id uint))
  (map-get? service-assignments service-id)
)

(define-read-only (get-resource-allocation (resource-id uint))
  (map-get? resource-allocations resource-id)
)

(define-read-only (get-milestone (milestone-id uint))
  (map-get? case-milestones milestone-id)
)

(define-read-only (get-case-count)
  (var-get case-counter)
)

(define-read-only (is-provider-certified (provider principal))
  (is-some (map-get? certified-providers provider))
)
