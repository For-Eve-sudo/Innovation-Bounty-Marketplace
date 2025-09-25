(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-INVALID-INPUT (err u400))
(define-constant ERR-BOUNTY-NOT-FOUND (err u404))
(define-constant ERR-SUBMISSION-NOT-FOUND (err u405))
(define-constant ERR-INSUFFICIENT-FUNDS (err u402))
(define-constant ERR-BOUNTY-CLOSED (err u403))
(define-constant ERR-ALREADY-SUBMITTED (err u406))
(define-constant ERR-DEADLINE-PASSED (err u407))
(define-constant ERR-INVALID-STATUS (err u408))
(define-constant ERR-NOT-REVIEWER (err u409))
(define-constant ERR-ALREADY-REVIEWED (err u410))

(define-constant CONTRACT-OWNER tx-sender)

(define-constant STATUS-ACTIVE u1)
(define-constant STATUS-UNDER-REVIEW u2)
(define-constant STATUS-COMPLETED u3)
(define-constant STATUS-CANCELLED u4)

(define-constant SUBMISSION-PENDING u1)
(define-constant SUBMISSION-ACCEPTED u2)
(define-constant SUBMISSION-REJECTED u3)

(define-constant REVIEW-PENDING u1)
(define-constant REVIEW-APPROVED u2)
(define-constant REVIEW-REJECTED u3)

(define-data-var bounty-nonce uint u0)
(define-data-var submission-nonce uint u0)
(define-data-var platform-fee uint u3)
(define-data-var min-bounty-amount uint u5000)

(define-map bounties
  { bounty-id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 1000),
    category: (string-ascii 50),
    reward-amount: uint,
    deadline: uint,
    created-at: uint,
    status: uint,
    required-skills: (list 5 (string-ascii 50)),
    submission-count: uint,
    winner-submission: (optional uint),
    reviewer: (optional principal)
  }
)

(define-map submissions
  { submission-id: uint }
  {
    bounty-id: uint,
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 1000),
    github-link: (string-ascii 200),
    demo-link: (string-ascii 200),
    submitted-at: uint,
    status: uint,
    review-score: (optional uint)
  }
)

(define-map bounty-reviews
  { bounty-id: uint, reviewer: principal }
  {
    assigned-at: uint,
    status: uint,
    expertise-areas: (list 3 (string-ascii 50))
  }
)

(define-map hunter-profiles
  { hunter: principal }
  {
    submissions-count: uint,
    bounties-won: uint,
    total-earned: uint,
    reputation-score: uint,
    skill-tags: (list 10 (string-ascii 50)),
    success-rate: uint
  }
)

(define-map bounty-funding
  { bounty-id: uint, backer: principal }
  {
    amount: uint,
    funded-at: uint
  }
)

(define-public (create-bounty
  (title (string-ascii 100))
  (description (string-ascii 1000))
  (category (string-ascii 50))
  (reward-amount uint)
  (duration-blocks uint)
  (required-skills (list 5 (string-ascii 50)))
)
  (let
    (
      (bounty-id (+ (var-get bounty-nonce) u1))
      (creator tx-sender)
      (deadline (+ stacks-block-height duration-blocks))
    )
    (asserts! (>= reward-amount (var-get min-bounty-amount)) ERR-INSUFFICIENT-FUNDS)
    (asserts! (> duration-blocks u0) ERR-INVALID-INPUT)
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u10) ERR-INVALID-INPUT)
    
    (try! (stx-transfer? reward-amount creator (as-contract tx-sender)))
    
    (map-set bounties
      {bounty-id: bounty-id}
      {
        creator: creator,
        title: title,
        description: description,
        category: category,
        reward-amount: reward-amount,
        deadline: deadline,
        created-at: stacks-block-height,
        status: STATUS-ACTIVE,
        required-skills: required-skills,
        submission-count: u0,
        winner-submission: none,
        reviewer: none
      }
    )
    
    (var-set bounty-nonce bounty-id)
    (ok bounty-id)
  )
)

(define-public (submit-solution
  (bounty-id uint)
  (title (string-ascii 100))
  (description (string-ascii 1000))
  (github-link (string-ascii 200))
  (demo-link (string-ascii 200))
)
  (let
    (
      (submission-id (+ (var-get submission-nonce) u1))
      (creator tx-sender)
      (bounty (unwrap! (map-get? bounties {bounty-id: bounty-id}) ERR-BOUNTY-NOT-FOUND))
    )
    (asserts! (is-eq (get status bounty) STATUS-ACTIVE) ERR-BOUNTY-CLOSED)
    (asserts! (< stacks-block-height (get deadline bounty)) ERR-DEADLINE-PASSED)
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u10) ERR-INVALID-INPUT)
    
    (map-set submissions
      {submission-id: submission-id}
      {
        bounty-id: bounty-id,
        creator: creator,
        title: title,
        description: description,
        github-link: github-link,
        demo-link: demo-link,
        submitted-at: stacks-block-height,
        status: SUBMISSION-PENDING,
        review-score: none
      }
    )
    
    (map-set bounties
      {bounty-id: bounty-id}
      (merge bounty {submission-count: (+ (get submission-count bounty) u1)})
    )
    
    (let
      (
        (profile (default-to
          {submissions-count: u0, bounties-won: u0, total-earned: u0, reputation-score: u100, skill-tags: (list), success-rate: u0}
          (map-get? hunter-profiles {hunter: creator})
        ))
      )
      (map-set hunter-profiles
        {hunter: creator}
        (merge profile {submissions-count: (+ (get submissions-count profile) u1)})
      )
    )
    
    (var-set submission-nonce submission-id)
    (ok submission-id)
  )
)

(define-public (assign-reviewer
  (bounty-id uint)
  (reviewer principal)
  (expertise-areas (list 3 (string-ascii 50)))
)
  (let
    (
      (bounty (unwrap! (map-get? bounties {bounty-id: bounty-id}) ERR-BOUNTY-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get creator bounty)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status bounty) STATUS-ACTIVE) ERR-INVALID-STATUS)
    (asserts! (is-none (get reviewer bounty)) ERR-ALREADY-SUBMITTED)
    (asserts! (> (get submission-count bounty) u0) ERR-INVALID-INPUT)
    
    (map-set bounties
      {bounty-id: bounty-id}
      (merge bounty {
        reviewer: (some reviewer),
        status: STATUS-UNDER-REVIEW
      })
    )
    
    (map-set bounty-reviews
      {bounty-id: bounty-id, reviewer: reviewer}
      {
        assigned-at: stacks-block-height,
        status: REVIEW-PENDING,
        expertise-areas: expertise-areas
      }
    )
    
    (ok true)
  )
)

(define-public (review-submission
  (submission-id uint)
  (review-score uint)
  (is-winner bool)
)
  (let
    (
      (submission (unwrap! (map-get? submissions {submission-id: submission-id}) ERR-SUBMISSION-NOT-FOUND))
      (bounty (unwrap! (map-get? bounties {bounty-id: (get bounty-id submission)}) ERR-BOUNTY-NOT-FOUND))
      (reviewer-info (map-get? bounty-reviews {bounty-id: (get bounty-id submission), reviewer: tx-sender}))
    )
    (asserts! (is-some reviewer-info) ERR-NOT-REVIEWER)
    (asserts! (is-eq (get status (unwrap! reviewer-info ERR-NOT-REVIEWER)) REVIEW-PENDING) ERR-ALREADY-REVIEWED)
    (asserts! (is-eq (get status bounty) STATUS-UNDER-REVIEW) ERR-INVALID-STATUS)
    (asserts! (<= review-score u100) ERR-INVALID-INPUT)
    
    (map-set submissions
      {submission-id: submission-id}
      (merge submission {
        review-score: (some review-score),
        status: (if is-winner SUBMISSION-ACCEPTED SUBMISSION-PENDING)
      })
    )
    
    (begin
      (if is-winner
        (begin
          (map-set bounties
            {bounty-id: (get bounty-id submission)}
            (merge bounty {
              winner-submission: (some submission-id),
              status: STATUS-COMPLETED
            })
          )
          (try! (distribute-reward (get bounty-id submission) submission-id))
        )
        false
      )
    )
    
    (map-set bounty-reviews
      {bounty-id: (get bounty-id submission), reviewer: tx-sender}
      (merge (unwrap! reviewer-info ERR-NOT-REVIEWER) {status: REVIEW-APPROVED})
    )
    
    (ok true)
  )
)

(define-public (fund-bounty (bounty-id uint) (amount uint))
  (let
    (
      (backer tx-sender)
      (bounty (unwrap! (map-get? bounties {bounty-id: bounty-id}) ERR-BOUNTY-NOT-FOUND))
    )
    (asserts! (not (is-eq (get status bounty) STATUS-COMPLETED)) ERR-BOUNTY-CLOSED)
    (asserts! (not (is-eq (get status bounty) STATUS-CANCELLED)) ERR-BOUNTY-CLOSED)
    (asserts! (> amount u0) ERR-INSUFFICIENT-FUNDS)
    
    (try! (stx-transfer? amount backer (as-contract tx-sender)))
    
    (map-set bounty-funding
      {bounty-id: bounty-id, backer: backer}
      {
        amount: amount,
        funded-at: stacks-block-height
      }
    )
    
    (map-set bounties
      {bounty-id: bounty-id}
      (merge bounty {reward-amount: (+ (get reward-amount bounty) amount)})
    )
    
    (ok true)
  )
)

(define-public (cancel-bounty (bounty-id uint))
  (let
    (
      (bounty (unwrap! (map-get? bounties {bounty-id: bounty-id}) ERR-BOUNTY-NOT-FOUND))
    )
    (asserts! (or 
      (is-eq tx-sender (get creator bounty))
      (is-eq tx-sender CONTRACT-OWNER)
    ) ERR-NOT-AUTHORIZED)
    (asserts! (not (is-eq (get status bounty) STATUS-COMPLETED)) ERR-INVALID-STATUS)
    
    (map-set bounties
      {bounty-id: bounty-id}
      (merge bounty {status: STATUS-CANCELLED})
    )
    
    (try! (as-contract (stx-transfer? (get reward-amount bounty) tx-sender (get creator bounty))))
    (ok true)
  )
)

(define-public (update-hunter-skills
  (hunter principal)
  (skill-tags (list 10 (string-ascii 50)))
)
  (let
    (
      (profile (default-to
        {submissions-count: u0, bounties-won: u0, total-earned: u0, reputation-score: u100, skill-tags: (list), success-rate: u0}
        (map-get? hunter-profiles {hunter: hunter})
      ))
    )
    (asserts! (is-eq tx-sender hunter) ERR-NOT-AUTHORIZED)
    
    (map-set hunter-profiles
      {hunter: hunter}
      (merge profile {skill-tags: skill-tags})
    )
    
    (ok true)
  )
)

(define-private (distribute-reward (bounty-id uint) (winner-submission-id uint))
  (let
    (
      (bounty (unwrap! (map-get? bounties {bounty-id: bounty-id}) ERR-BOUNTY-NOT-FOUND))
      (submission (unwrap! (map-get? submissions {submission-id: winner-submission-id}) ERR-SUBMISSION-NOT-FOUND))
      (total-reward (get reward-amount bounty))
      (platform-fee-amount (/ (* total-reward (var-get platform-fee)) u100))
      (winner-amount (- total-reward platform-fee-amount))
      (winner (get creator submission))
    )
    
    (try! (as-contract (stx-transfer? winner-amount tx-sender winner)))
    
    (let
      (
        (profile (default-to
          {submissions-count: u0, bounties-won: u0, total-earned: u0, reputation-score: u100, skill-tags: (list), success-rate: u0}
          (map-get? hunter-profiles {hunter: winner})
        ))
      )
      (map-set hunter-profiles
        {hunter: winner}
        (merge profile {
          bounties-won: (+ (get bounties-won profile) u1),
          total-earned: (+ (get total-earned profile) winner-amount),
          reputation-score: (+ (get reputation-score profile) u25),
          success-rate: (/ (* (+ (get bounties-won profile) u1) u100) (get submissions-count profile))
        })
      )
    )
    
    (ok true)
  )
)

(define-read-only (get-bounty (bounty-id uint))
  (map-get? bounties {bounty-id: bounty-id})
)

(define-read-only (get-submission (submission-id uint))
  (map-get? submissions {submission-id: submission-id})
)

(define-read-only (get-hunter-profile (hunter principal))
  (map-get? hunter-profiles {hunter: hunter})
)

(define-read-only (get-bounty-review (bounty-id uint) (reviewer principal))
  (map-get? bounty-reviews {bounty-id: bounty-id, reviewer: reviewer})
)

(define-read-only (get-bounty-funding (bounty-id uint) (backer principal))
  (map-get? bounty-funding {bounty-id: bounty-id, backer: backer})
)

(define-read-only (get-platform-stats)
  {
    total-bounties: (var-get bounty-nonce),
    total-submissions: (var-get submission-nonce),
    platform-fee: (var-get platform-fee),
    min-bounty-amount: (var-get min-bounty-amount)
  }
)

(define-public (set-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= new-fee u10) ERR-INVALID-INPUT)
    (var-set platform-fee new-fee)
    (ok true)
  )
)

(define-public (set-min-bounty-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> new-amount u0) ERR-INVALID-INPUT)
    (var-set min-bounty-amount new-amount)
    (ok true)
  )
)

(begin
  (var-set platform-fee u3)
  (var-set min-bounty-amount u5000)
)