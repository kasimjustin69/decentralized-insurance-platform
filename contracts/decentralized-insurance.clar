;; Decentralized Insurance Platform Smart Contract
;; A comprehensive peer-to-peer insurance system with automated claims processing

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_INVALID_INPUT (err u102))
(define-constant ERR_INSUFFICIENT_FUNDS (err u103))
(define-constant ERR_POLICY_EXPIRED (err u104))
(define-constant ERR_CLAIM_ALREADY_SUBMITTED (err u105))
(define-constant ERR_CLAIM_NOT_VALID (err u106))
(define-constant ERR_PREMIUM_NOT_PAID (err u107))
(define-constant ERR_POLICY_CANCELLED (err u108))
(define-constant ERR_CLAIM_EXPIRED (err u109))
(define-constant ERR_INSUFFICIENT_POOL_FUNDS (err u110))
(define-constant ERR_RISK_TOO_HIGH (err u111))
(define-constant ERR_INVALID_COVERAGE_AMOUNT (err u112))

;; Data Variables
(define-data-var next-policy-id uint u1)
(define-data-var next-claim-id uint u1)
(define-data-var next-provider-id uint u1)
(define-data-var platform-admin principal CONTRACT_OWNER)
(define-data-var platform-fee-rate uint u500) ;; 5% platform fee
(define-data-var minimum-premium uint u1000000) ;; 1 STX minimum premium
(define-data-var maximum-coverage uint u1000000000000) ;; 1M STX maximum coverage
(define-data-var claim-investigation-period uint u4320) ;; ~30 days in blocks
(define-data-var total-premium-pool uint u0)
(define-data-var total-claims-paid uint u0)

;; Insurance Product Types
(define-constant INSURANCE_LIFE u0)
(define-constant INSURANCE_HEALTH u1)
(define-constant INSURANCE_AUTO u2)
(define-constant INSURANCE_PROPERTY u3)
(define-constant INSURANCE_TRAVEL u4)
(define-constant INSURANCE_CYBER u5)
(define-constant INSURANCE_BUSINESS u6)
(define-constant INSURANCE_CROP u7)
(define-constant INSURANCE_MARINE u8)
(define-constant INSURANCE_PARAMETRIC u9)

;; Policy Status
(define-constant POLICY_STATUS_ACTIVE u0)
(define-constant POLICY_STATUS_EXPIRED u1)
(define-constant POLICY_STATUS_CANCELLED u2)
(define-constant POLICY_STATUS_SUSPENDED u3)
(define-constant POLICY_STATUS_LAPSED u4)

;; Claim Status
(define-constant CLAIM_STATUS_SUBMITTED u0)
(define-constant CLAIM_STATUS_INVESTIGATING u1)
(define-constant CLAIM_STATUS_APPROVED u2)
(define-constant CLAIM_STATUS_REJECTED u3)
(define-constant CLAIM_STATUS_PAID u4)
(define-constant CLAIM_STATUS_DISPUTED u5)

;; Risk Levels
(define-constant RISK_LEVEL_LOW u0)
(define-constant RISK_LEVEL_MEDIUM u1)
(define-constant RISK_LEVEL_HIGH u2)
(define-constant RISK_LEVEL_VERY_HIGH u3)

;; Data Maps

;; Insurance providers registry
(define-map insurance-providers
    { provider-id: uint }
    {
        name: (string-ascii 100),
        principal: principal,
        license-number: (string-ascii 50),
        specialty: uint,
        reputation-score: uint,
        total-policies: uint,
        total-claims-handled: uint,
        success-rate: uint,
        capital-reserves: uint,
        active: bool,
        registered-at: uint
    }
)

;; Provider lookup by principal
(define-map provider-principals
    { principal: principal }
    { provider-id: uint }
)

;; Insurance policies with comprehensive details
(define-map insurance-policies
    { policy-id: uint }
    {
        provider-id: uint,
        policyholder: principal,
        insurance-type: uint,
        coverage-amount: uint,
        premium-amount: uint,
        premium-frequency: uint, ;; blocks between premium payments
        policy-start: uint,
        policy-end: uint,
        status: uint,
        risk-level: uint,
        deductible: uint,
        last-premium-paid: uint,
        next-premium-due: uint,
        total-premiums-paid: uint,
        claims-count: uint,
        beneficiaries: (list 5 principal),
        terms-hash: (buff 32),
        metadata: (string-ascii 500)
    }
)

;; Premium payment tracking
(define-map premium-payments
    { policy-id: uint, payment-id: uint }
    {
        amount: uint,
        payment-date: uint,
        due-date: uint,
        late-fee: uint,
        grace-period-used: bool
    }
)

;; Insurance claims with detailed information
(define-map insurance-claims
    { claim-id: uint }
    {
        policy-id: uint,
        claimant: principal,
        claim-type: (string-ascii 50),
        incident-date: uint,
        reported-date: uint,
        claim-amount: uint,
        status: uint,
        description: (string-ascii 500),
        evidence-hash: (buff 32),
        investigation-notes: (string-ascii 300),
        adjuster: (optional principal),
        settlement-amount: uint,
        settlement-date: (optional uint),
        dispute-reason: (optional (string-ascii 200)),
        approval-votes: uint,
        rejection-votes: uint,
        validators: (list 10 principal)
    }
)

;; Risk assessment profiles
(define-map risk-profiles
    { principal: principal, insurance-type: uint }
    {
        age: uint,
        occupation: (string-ascii 50),
        location: (string-ascii 50),
        health-score: uint,
        credit-score: uint,
        previous-claims: uint,
        risk-factors: (list 10 (string-ascii 50)),
        assessment-date: uint,
        risk-score: uint,
        premium-multiplier: uint
    }
)

;; Premium pools for different insurance types
(define-map premium-pools
    { insurance-type: uint }
    {
        total-premiums: uint,
        total-claims: uint,
        reserve-amount: uint,
        investment-income: uint,
        administrative-costs: uint,
        loss-ratio: uint,
        participants: uint,
        last-updated: uint
    }
)

;; Claims validation and consensus
(define-map claim-validators
    { claim-id: uint, validator: principal }
    {
        vote: bool,
        reasoning: (string-ascii 200),
        expertise-level: uint,
        validation-date: uint,
        reward-earned: uint
    }
)

;; Oracle data integration
(define-map oracle-data
    { data-type: (string-ascii 50), timestamp: uint }
    {
        data-source: (string-ascii 100),
        data-value: (string-ascii 200),
        reliability-score: uint,
        verified: bool,
        used-in-claims: (list 20 uint)
    }
)

;; Reinsurance contracts
(define-map reinsurance-contracts
    { reinsurance-id: uint }
    {
        reinsurer: principal,
        coverage-amount: uint,
        premium-rate: uint,
        covered-risks: (list 10 uint),
        attachment-point: uint,
        active: bool,
        contract-start: uint,
        contract-end: uint
    }
)

;; Governance proposals
(define-map governance-proposals
    { proposal-id: uint }
    {
        proposer: principal,
        title: (string-ascii 100),
        description: (string-ascii 500),
        proposal-type: uint,
        voting-start: uint,
        voting-end: uint,
        votes-for: uint,
        votes-against: uint,
        executed: bool,
        minimum-quorum: uint
    }
)

;; Platform analytics and metrics
(define-map platform-analytics
    { metric-name: (string-ascii 50) }
    { metric-value: uint }
)

;; Provider Registration Functions

;; Register as insurance provider
(define-public (register-insurance-provider
    (name (string-ascii 100))
    (license-number (string-ascii 50))
    (specialty uint)
    (initial-capital uint)
)
    (let (
        (provider-id (var-get next-provider-id))
        (caller tx-sender)
    )
        ;; Input validation
        (asserts! (> (len name) u0) ERR_INVALID_INPUT)
        (asserts! (> (len license-number) u0) ERR_INVALID_INPUT)
        (asserts! (<= specialty INSURANCE_PARAMETRIC) ERR_INVALID_INPUT)
        (asserts! (>= initial-capital u10000000) ERR_INSUFFICIENT_FUNDS) ;; Minimum 10 STX capital
        
        ;; Check if already registered
        (asserts! (is-none (map-get? provider-principals { principal: caller })) ERR_UNAUTHORIZED)
        
        ;; Transfer initial capital to platform
        (try! (stx-transfer? initial-capital caller (as-contract tx-sender)))
        
        ;; Create provider record
        (map-set insurance-providers
            { provider-id: provider-id }
            {
                name: name,
                principal: caller,
                license-number: license-number,
                specialty: specialty,
                reputation-score: u100,
                total-policies: u0,
                total-claims-handled: u0,
                success-rate: u100,
                capital-reserves: initial-capital,
                active: true,
                registered-at: block-height
            }
        )
        
        ;; Map principal to provider
        (map-set provider-principals
            { principal: caller }
            { provider-id: provider-id }
        )
        
        ;; Update analytics
        (increment-metric "total-providers")
        
        ;; Increment provider ID
        (var-set next-provider-id (+ provider-id u1))
        
        (ok provider-id)
    )
)

;; Policy Creation and Management Functions

;; Create insurance policy
(define-public (create-policy
    (insurance-type uint)
    (coverage-amount uint)
    (policy-duration uint)
    (beneficiaries (list 5 principal))
    (terms-hash (buff 32))
    (metadata (string-ascii 500))
)
    (let (
        (policy-id (var-get next-policy-id))
        (caller tx-sender)
        (risk-assessment (get-risk-assessment caller insurance-type))
        (premium (calculate-premium insurance-type coverage-amount (get risk-score risk-assessment)))
        (provider-lookup (map-get? provider-principals { principal: tx-sender }))
    )
        ;; Input validation
        (asserts! (<= insurance-type INSURANCE_PARAMETRIC) ERR_INVALID_INPUT)
        (asserts! (and 
            (>= coverage-amount (var-get minimum-premium))
            (<= coverage-amount (var-get maximum-coverage))
        ) ERR_INVALID_COVERAGE_AMOUNT)
        (asserts! (> policy-duration u0) ERR_INVALID_INPUT)
        (asserts! (< (get risk-score risk-assessment) u80) ERR_RISK_TOO_HIGH)
        
        ;; Check if caller is registered provider (for now, allow direct policy creation)
        ;; (asserts! (is-some provider-lookup) ERR_UNAUTHORIZED)
        
        ;; Create policy record
        (map-set insurance-policies
            { policy-id: policy-id }
            {
                provider-id: u0, ;; Default provider for direct policies
                policyholder: caller,
                insurance-type: insurance-type,
                coverage-amount: coverage-amount,
                premium-amount: premium,
                premium-frequency: u4320, ;; Monthly payments (~30 days)
                policy-start: block-height,
                policy-end: (+ block-height policy-duration),
                status: POLICY_STATUS_ACTIVE,
                risk-level: (get-risk-level (get risk-score risk-assessment)),
                deductible: (/ coverage-amount u10), ;; 10% deductible
                last-premium-paid: u0,
                next-premium-due: (+ block-height u4320),
                total-premiums-paid: u0,
                claims-count: u0,
                beneficiaries: beneficiaries,
                terms-hash: terms-hash,
                metadata: metadata
            }
        )
        
        ;; Initialize premium pool if needed
        (if (is-none (map-get? premium-pools { insurance-type: insurance-type }))
            (map-set premium-pools
                { insurance-type: insurance-type }
                {
                    total-premiums: u0,
                    total-claims: u0,
                    reserve-amount: u0,
                    investment-income: u0,
                    administrative-costs: u0,
                    loss-ratio: u0,
                    participants: u0,
                    last-updated: block-height
                }
            )
            true
        )
        
        ;; Update analytics
        (increment-metric "total-policies")
        (increment-metric (concat-strings "policies-" (uint-to-string insurance-type)))
        
        ;; Increment policy ID
        (var-set next-policy-id (+ policy-id u1))
        
        (ok policy-id)
    )
)

;; Pay premium
(define-public (pay-premium (policy-id uint))
    (let (
        (policy (unwrap! (map-get? insurance-policies { policy-id: policy-id }) ERR_NOT_FOUND))
        (caller tx-sender)
        (premium-amount (get premium-amount policy))
        (platform-fee (/ (* premium-amount (var-get platform-fee-rate)) u10000))
        (pool-amount (- premium-amount platform-fee))
    )
        ;; Verify caller is policyholder
        (asserts! (is-eq caller (get policyholder policy)) ERR_UNAUTHORIZED)
        
        ;; Check policy is active
        (asserts! (is-eq (get status policy) POLICY_STATUS_ACTIVE) ERR_POLICY_CANCELLED)
        (asserts! (<= block-height (get policy-end policy)) ERR_POLICY_EXPIRED)
        
        ;; Transfer premium payment
        (try! (stx-transfer? premium-amount caller (as-contract tx-sender)))
        
        ;; Update premium pool
        (let (
            (pool (unwrap! (map-get? premium-pools { insurance-type: (get insurance-type policy) }) ERR_NOT_FOUND))
        )
            (map-set premium-pools
                { insurance-type: (get insurance-type policy) }
                (merge pool {
                    total-premiums: (+ (get total-premiums pool) pool-amount),
                    participants: (+ (get participants pool) u1),
                    last-updated: block-height
                })
            )
        )
        
        ;; Update policy payment status
        (map-set insurance-policies
            { policy-id: policy-id }
            (merge policy {
                last-premium-paid: block-height,
                next-premium-due: (+ block-height (get premium-frequency policy)),
                total-premiums-paid: (+ (get total-premiums-paid policy) premium-amount)
            })
        )
        
        ;; Update total premium pool
        (var-set total-premium-pool (+ (var-get total-premium-pool) pool-amount))
        
        ;; Update analytics
        (increment-metric "premium-payments")
        
        (ok true)
    )
)

;; Claims Processing Functions

;; Submit insurance claim
(define-public (submit-claim
    (policy-id uint)
    (claim-type (string-ascii 50))
    (incident-date uint)
    (claim-amount uint)
    (description (string-ascii 500))
    (evidence-hash (buff 32))
)
    (let (
        (claim-id (var-get next-claim-id))
        (policy (unwrap! (map-get? insurance-policies { policy-id: policy-id }) ERR_NOT_FOUND))
        (caller tx-sender)
    )
        ;; Verify caller is policyholder or beneficiary
        (asserts! (or 
            (is-eq caller (get policyholder policy))
            (is-some (index-of (get beneficiaries policy) caller))
        ) ERR_UNAUTHORIZED)
        
        ;; Validate policy is active and premiums are current
        (asserts! (is-eq (get status policy) POLICY_STATUS_ACTIVE) ERR_POLICY_CANCELLED)
        (asserts! (<= block-height (get policy-end policy)) ERR_POLICY_EXPIRED)
        (asserts! (> (get total-premiums-paid policy) u0) ERR_PREMIUM_NOT_PAID)
        
        ;; Validate claim parameters
        (asserts! (> (len claim-type) u0) ERR_INVALID_INPUT)
        (asserts! (<= incident-date block-height) ERR_INVALID_INPUT)
        (asserts! (<= claim-amount (get coverage-amount policy)) ERR_INVALID_INPUT)
        (asserts! (>= claim-amount (get deductible policy)) ERR_INVALID_INPUT)
        
        ;; Create claim record
        (map-set insurance-claims
            { claim-id: claim-id }
            {
                policy-id: policy-id,
                claimant: caller,
                claim-type: claim-type,
                incident-date: incident-date,
                reported-date: block-height,
                claim-amount: claim-amount,
                status: CLAIM_STATUS_SUBMITTED,
                description: description,
                evidence-hash: evidence-hash,
                investigation-notes: "",
                adjuster: none,
                settlement-amount: u0,
                settlement-date: none,
                dispute-reason: none,
                approval-votes: u0,
                rejection-votes: u0,
                validators: (list)
            }
        )
        
        ;; Update policy claims count
        (map-set insurance-policies
            { policy-id: policy-id }
            (merge policy {
                claims-count: (+ (get claims-count policy) u1)
            })
        )
        
        ;; Update analytics
        (increment-metric "total-claims")
        (increment-metric (concat-strings "claims-" (uint-to-string (get insurance-type policy))))
        
        ;; Increment claim ID
        (var-set next-claim-id (+ claim-id u1))
        
        (ok claim-id)
    )
)

;; Validate claim (by validators/adjusters)
(define-public (validate-claim
    (claim-id uint)
    (approve bool)
    (reasoning (string-ascii 200))
    (expertise-level uint)
)
    (let (
        (claim (unwrap! (map-get? insurance-claims { claim-id: claim-id }) ERR_NOT_FOUND))
        (caller tx-sender)
        (validation-key { claim-id: claim-id, validator: caller })
    )
        ;; Check if claim is in valid status for validation
        (asserts! (or 
            (is-eq (get status claim) CLAIM_STATUS_SUBMITTED)
            (is-eq (get status claim) CLAIM_STATUS_INVESTIGATING)
        ) ERR_CLAIM_NOT_VALID)
        
        ;; Prevent double voting
        (asserts! (is-none (map-get? claim-validators validation-key)) ERR_CLAIM_ALREADY_SUBMITTED)
        
        ;; Record validation
        (map-set claim-validators
            validation-key
            {
                vote: approve,
                reasoning: reasoning,
                expertise-level: expertise-level,
                validation-date: block-height,
                reward-earned: u0 ;; To be calculated later
            }
        )
        
        ;; Update claim vote counts
        (begin
            (if approve
                (map-set insurance-claims
                    { claim-id: claim-id }
                    (merge claim {
                        status: CLAIM_STATUS_INVESTIGATING,
                        approval-votes: (+ (get approval-votes claim) u1),
                        validators: (unwrap-panic (as-max-len? 
                            (append (get validators claim) caller) u10))
                    })
                )
                (map-set insurance-claims
                    { claim-id: claim-id }
                    (merge claim {
                        status: CLAIM_STATUS_INVESTIGATING,
                        rejection-votes: (+ (get rejection-votes claim) u1),
                        validators: (unwrap-panic (as-max-len? 
                            (append (get validators claim) caller) u10))
                    })
                )
            )
            (ok true)
        )
    )
)

;; Process approved claim
(define-private (process-claim-approval (claim-id uint))
    (let (
        (claim (unwrap! (map-get? insurance-claims { claim-id: claim-id }) ERR_NOT_FOUND))
        (policy (unwrap! (map-get? insurance-policies { policy-id: (get policy-id claim) }) ERR_NOT_FOUND))
        (pool (unwrap! (map-get? premium-pools { insurance-type: (get insurance-type policy) }) ERR_NOT_FOUND))
        (settlement-amount (- (get claim-amount claim) (get deductible policy)))
    )
        ;; Check if pool has sufficient funds
        (asserts! (>= (get total-premiums pool) settlement-amount) ERR_INSUFFICIENT_POOL_FUNDS)
        
        ;; Update claim status
        (map-set insurance-claims
            { claim-id: claim-id }
            (merge claim {
                status: CLAIM_STATUS_APPROVED,
                settlement-amount: settlement-amount,
                settlement-date: (some block-height)
            })
        )
        
        ;; Transfer payout to claimant
        (try! (as-contract (stx-transfer? settlement-amount tx-sender (get claimant claim))))
        
        ;; Update premium pool
        (map-set premium-pools
            { insurance-type: (get insurance-type policy) }
            (merge pool {
                total-claims: (+ (get total-claims pool) settlement-amount),
                reserve-amount: (- (get total-premiums pool) settlement-amount),
                loss-ratio: (/ (* (+ (get total-claims pool) settlement-amount) u100) 
                            (get total-premiums pool)),
                last-updated: block-height
            })
        )
        
        ;; Update global claims paid
        (var-set total-claims-paid (+ (var-get total-claims-paid) settlement-amount))
        
        ;; Update analytics
        (increment-metric "claims-approved")
        (increment-metric "total-payouts")
        
        (ok true)
    )
)

;; Process rejected claim
(define-private (process-claim-rejection (claim-id uint))
    (let (
        (claim (unwrap! (map-get? insurance-claims { claim-id: claim-id }) ERR_NOT_FOUND))
    )
        ;; Update claim status
        (map-set insurance-claims
            { claim-id: claim-id }
            (merge claim {
                status: CLAIM_STATUS_REJECTED,
                settlement-amount: u0
            })
        )
        
        ;; Update analytics
        (increment-metric "claims-rejected")
        
        (ok true)
    )
)

;; Risk Assessment Functions

;; Update risk profile
(define-public (update-risk-profile
    (insurance-type uint)
    (age uint)
    (occupation (string-ascii 50))
    (location (string-ascii 50))
    (health-score uint)
    (credit-score uint)
    (risk-factors (list 10 (string-ascii 50)))
)
    (let (
        (caller tx-sender)
        (risk-score (calculate-risk-score age health-score credit-score (len risk-factors)))
        (premium-multiplier (get-premium-multiplier risk-score))
    )
        ;; Input validation
        (asserts! (<= insurance-type INSURANCE_PARAMETRIC) ERR_INVALID_INPUT)
        (asserts! (and (>= age u18) (<= age u100)) ERR_INVALID_INPUT)
        (asserts! (> (len occupation) u0) ERR_INVALID_INPUT)
        (asserts! (<= health-score u100) ERR_INVALID_INPUT)
        (asserts! (<= credit-score u850) ERR_INVALID_INPUT)
        
        ;; Create or update risk profile
        (map-set risk-profiles
            { principal: caller, insurance-type: insurance-type }
            {
                age: age,
                occupation: occupation,
                location: location,
                health-score: health-score,
                credit-score: credit-score,
                previous-claims: (get-previous-claims-count caller),
                risk-factors: risk-factors,
                assessment-date: block-height,
                risk-score: risk-score,
                premium-multiplier: premium-multiplier
            }
        )
        
        (ok risk-score)
    )
)

;; Utility Functions

;; Get risk assessment for user
(define-private (get-risk-assessment (user principal) (insurance-type uint))
    (default-to
        {
            age: u30,
            occupation: "Unknown",
            location: "Unknown",
            health-score: u50,
            credit-score: u600,
            previous-claims: u0,
            risk-factors: (list),
            assessment-date: block-height,
            risk-score: u50,
            premium-multiplier: u100
        }
        (map-get? risk-profiles { principal: user, insurance-type: insurance-type })
    )
)

;; Calculate premium based on coverage and risk
(define-private (calculate-premium (insurance-type uint) (coverage-amount uint) (risk-score uint))
    (let (
        (base-rate (get-base-rate insurance-type))
        (risk-multiplier (+ u50 risk-score)) ;; 50-150% based on risk
        (coverage-factor (/ coverage-amount u100000)) ;; Scale based on coverage
    )
        (/ (* (* base-rate coverage-factor) risk-multiplier) u10000)
    )
)

;; Get base insurance rate by type
(define-private (get-base-rate (insurance-type uint))
    (if (is-eq insurance-type INSURANCE_LIFE) u100
    (if (is-eq insurance-type INSURANCE_HEALTH) u200
    (if (is-eq insurance-type INSURANCE_AUTO) u150
    (if (is-eq insurance-type INSURANCE_PROPERTY) u80
    (if (is-eq insurance-type INSURANCE_TRAVEL) u50
    (if (is-eq insurance-type INSURANCE_CYBER) u300
    (if (is-eq insurance-type INSURANCE_BUSINESS) u250
    (if (is-eq insurance-type INSURANCE_CROP) u120
    (if (is-eq insurance-type INSURANCE_MARINE) u180
    (if (is-eq insurance-type INSURANCE_PARAMETRIC) u90
    u100))))))))))
)

;; Calculate risk score based on factors
(define-private (calculate-risk-score (age uint) (health-score uint) (credit-score uint) (risk-factors-count uint))
    (let (
        (age-score (if (<= age u25) u20 (if (<= age u35) u10 (if (<= age u50) u0 (if (<= age u65) u10 u20)))))
        (health-factor (/ (- u100 health-score) u2))
        (credit-factor (if (>= credit-score u700) u0 (if (>= credit-score u600) u10 u20)))
        (risk-factor-penalty (* risk-factors-count u5))
    )
        (+ age-score health-factor credit-factor risk-factor-penalty)
    )
)

;; Get risk level from score
(define-private (get-risk-level (risk-score uint))
    (if (<= risk-score u25) RISK_LEVEL_LOW
    (if (<= risk-score u50) RISK_LEVEL_MEDIUM
    (if (<= risk-score u75) RISK_LEVEL_HIGH
    RISK_LEVEL_VERY_HIGH)))
)

;; Get premium multiplier from risk score
(define-private (get-premium-multiplier (risk-score uint))
    (if (<= risk-score u25) u80    ;; 20% discount for low risk
    (if (<= risk-score u50) u100   ;; Standard rate
    (if (<= risk-score u75) u130   ;; 30% increase for high risk
    u160)))                        ;; 60% increase for very high risk
)

;; Get previous claims count for user
(define-private (get-previous-claims-count (user principal))
    ;; This would be calculated from historical data
    ;; For now, return 0
    u0
)

;; Query Functions

;; Get policy details
(define-read-only (get-policy-details (policy-id uint))
    (map-get? insurance-policies { policy-id: policy-id })
)

;; Get claim details
(define-read-only (get-claim-details (claim-id uint))
    (map-get? insurance-claims { claim-id: claim-id })
)

;; Get premium pool status
(define-read-only (get-pool-status (insurance-type uint))
    (map-get? premium-pools { insurance-type: insurance-type })
)

;; Get platform statistics
(define-read-only (get-platform-stats)
    (ok {
        total-premium-pool: (var-get total-premium-pool),
        total-claims-paid: (var-get total-claims-paid),
        total-policies: (get-metric "total-policies"),
        total-claims: (get-metric "total-claims"),
        platform-fee-rate: (var-get platform-fee-rate)
    })
)

;; Administrative Functions

;; Update platform parameters (admin only)
(define-public (update-platform-parameters
    (new-fee-rate uint)
    (new-min-premium uint)
    (new-max-coverage uint)
    (new-investigation-period uint)
)
    (begin
        (asserts! (is-eq tx-sender (var-get platform-admin)) ERR_UNAUTHORIZED)
        (asserts! (<= new-fee-rate u2000) ERR_INVALID_INPUT) ;; Max 20% fee
        
        (var-set platform-fee-rate new-fee-rate)
        (var-set minimum-premium new-min-premium)
        (var-set maximum-coverage new-max-coverage)
        (var-set claim-investigation-period new-investigation-period)
        
        (ok true)
    )
)

;; Emergency pause (admin only)
(define-public (emergency-pause)
    (begin
        (asserts! (is-eq tx-sender (var-get platform-admin)) ERR_UNAUTHORIZED)
        ;; Implementation would add pause functionality
        (ok true)
    )
)

;; Helper Functions

;; Increment metric counter
(define-private (increment-metric (metric-name (string-ascii 50)))
    (let (
        (current-value (get-metric metric-name))
    )
        (map-set platform-analytics
            { metric-name: metric-name }
            { metric-value: (+ current-value u1) }
        )
    )
)

;; Get metric value
(define-private (get-metric (metric-name (string-ascii 50)))
    (default-to u0 (get metric-value (map-get? platform-analytics { metric-name: metric-name })))
)

;; Convert uint to string (simplified)
(define-private (uint-to-string (value uint))
    (if (is-eq value u0) "0"
    (if (is-eq value u1) "1"
    (if (is-eq value u2) "2"
    (if (is-eq value u3) "3"
    (if (is-eq value u4) "4"
    (if (is-eq value u5) "5"
    (if (is-eq value u6) "6"
    (if (is-eq value u7) "7"
    (if (is-eq value u8) "8"
    (if (is-eq value u9) "9"
    "unknown"))))))))))
)

;; Concatenate strings (simplified)
(define-private (concat-strings (str1 (string-ascii 50)) (str2 (string-ascii 50)))
    ;; Simplified concatenation - in real implementation would properly concatenate
    str1
)

;; Initialize contract with default pools
(define-private (initialize-pools)
    (begin
        ;; Initialize premium pools for each insurance type
        (map-set premium-pools { insurance-type: INSURANCE_LIFE } {
            total-premiums: u0, total-claims: u0, reserve-amount: u0,
            investment-income: u0, administrative-costs: u0, loss-ratio: u0,
            participants: u0, last-updated: block-height
        })
        (map-set premium-pools { insurance-type: INSURANCE_HEALTH } {
            total-premiums: u0, total-claims: u0, reserve-amount: u0,
            investment-income: u0, administrative-costs: u0, loss-ratio: u0,
            participants: u0, last-updated: block-height
        })
        (map-set premium-pools { insurance-type: INSURANCE_AUTO } {
            total-premiums: u0, total-claims: u0, reserve-amount: u0,
            investment-income: u0, administrative-costs: u0, loss-ratio: u0,
            participants: u0, last-updated: block-height
        })
        
        ;; Initialize analytics
        (map-set platform-analytics { metric-name: "total-policies" } { metric-value: u0 })
        (map-set platform-analytics { metric-name: "total-claims" } { metric-value: u0 })
        (map-set platform-analytics { metric-name: "total-providers" } { metric-value: u0 })
        (map-set platform-analytics { metric-name: "premium-payments" } { metric-value: u0 })
        
        true
    )
)

;; Initialize contract on deployment
(initialize-pools)