;; Event Cancellation Insurance - Risk Assessment Contract
;; Evaluates risk factors and calculates premium adjustments

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-INVALID-RISK-FACTOR (err u501))
(define-constant ERR-INVALID-LOCATION (err u502))
(define-constant ERR-INVALID-DATE (err u503))

;; Data Variables
(define-data-var base-risk-score uint u100)
(define-data-var seasonal-adjustment-active bool true)

;; Risk factor weights and multipliers
(define-map risk-factors (string-ascii 30) {
  weight: uint,
  max-impact: uint,
  active: bool
})

;; Initialize risk factors
(map-set risk-factors "weather-history" {weight: u25, max-impact: u200, active: true})
(map-set risk-factors "event-type" {weight: u20, max-impact: u150, active: true})
(map-set risk-factors "location-risk" {weight: u15, max-impact: u180, active: true})
(map-set risk-factors "seasonal-timing" {weight: u15, max-impact: u140, active: true})
(map-set risk-factors "advance-booking" {weight: u10, max-impact: u120, active: true})
(map-set risk-factors "event-duration" {weight: u10, max-impact: u130, active: true})
(map-set risk-factors "attendance-size" {weight: u5, max-impact: u110, active: true})

;; Location-based risk profiles
(define-map location-risk-profiles {latitude: int, longitude: int} {
  weather-risk-score: uint,
  natural-disaster-risk: uint,
  infrastructure-risk: uint,
  seasonal-patterns: (list 12 uint), ;; Monthly risk scores
  last-updated: uint
})

;; Event type risk profiles
(define-map event-type-risks (string-ascii 50) {
  base-risk-multiplier: uint,
  weather-sensitivity: uint,
  cancellation-history: uint,
  typical-lead-time: uint,
  vendor-complexity: uint
})

;; Historical risk data
(define-map historical-risk-events {location: {latitude: int, longitude: int}, year: uint} {
  severe-weather-days: uint,
  cancellation-rate: uint,
  average-loss: uint,
  event-count: uint
})

;; Risk assessment results cache
(define-map risk-assessments (buff 32) {
  overall-risk-score: uint,
  premium-multiplier: uint,
  risk-breakdown: {
    weather: uint,
    location: uint,
    timing: uint,
    event-type: uint,
    other: uint
  },
  assessed-at: uint,
  valid-until: uint
})

;; Public Functions

;; Perform comprehensive risk assessment
(define-public (assess-event-risk
  (event-type (string-ascii 50))
  (location {latitude: int, longitude: int})
  (event-date uint)
  (event-duration uint)
  (expected-attendance uint)
  (advance-booking-days uint))
  (let ((assessment-hash (generate-assessment-hash event-type location event-date))
        (weather-risk (calculate-weather-risk location event-date))
        (location-risk (calculate-location-risk location))
        (timing-risk (calculate-timing-risk event-date advance-booking-days))
        (event-type-risk (calculate-event-type-risk event-type))
        (duration-risk (calculate-duration-risk event-duration))
        (attendance-risk (calculate-attendance-risk expected-attendance)))

    (let ((overall-score (calculate-weighted-risk-score
                          weather-risk location-risk timing-risk
                          event-type-risk duration-risk attendance-risk))
          (premium-multiplier (risk-score-to-premium-multiplier overall-score)))

      (map-set risk-assessments assessment-hash {
        overall-risk-score: overall-score,
        premium-multiplier: premium-multiplier,
        risk-breakdown: {
          weather: weather-risk,
          location: location-risk,
          timing: timing-risk,
          event-type: event-type-risk,
          other: (+ duration-risk attendance-risk)
        },
        assessed-at: block-height,
        valid-until: (+ block-height u1440) ;; Valid for 24 hours
      })

      (ok {
        assessment-hash: assessment-hash,
        risk-score: overall-score,
        premium-multiplier: premium-multiplier
      }))))

;; Update location risk profile
(define-public (update-location-risk-profile
  (location {latitude: int, longitude: int})
  (weather-risk-score uint)
  (natural-disaster-risk uint)
  (infrastructure-risk uint)
  (seasonal-patterns (list 12 uint)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-coordinates location) ERR-INVALID-LOCATION)

    (map-set location-risk-profiles location {
      weather-risk-score: weather-risk-score,
      natural-disaster-risk: natural-disaster-risk,
      infrastructure-risk: infrastructure-risk,
      seasonal-patterns: seasonal-patterns,
      last-updated: block-height
    })
    (ok true)))

;; Update event type risk profile
(define-public (update-event-type-risk
  (event-type (string-ascii 50))
  (base-risk-multiplier uint)
  (weather-sensitivity uint)
  (cancellation-history uint)
  (typical-lead-time uint)
  (vendor-complexity uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set event-type-risks event-type {
      base-risk-multiplier: base-risk-multiplier,
      weather-sensitivity: weather-sensitivity,
      cancellation-history: cancellation-history,
      typical-lead-time: typical-lead-time,
      vendor-complexity: vendor-complexity
    })
    (ok true)))

;; Add historical risk data
(define-public (add-historical-risk-data
  (location {latitude: int, longitude: int})
  (year uint)
  (severe-weather-days uint)
  (cancellation-rate uint)
  (average-loss uint)
  (event-count uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-coordinates location) ERR-INVALID-LOCATION)

    (map-set historical-risk-events {location: location, year: year} {
      severe-weather-days: severe-weather-days,
      cancellation-rate: cancellation-rate,
      average-loss: average-loss,
      event-count: event-count
    })
    (ok true)))

;; Read-only Functions

;; Get risk assessment by hash
(define-read-only (get-risk-assessment (assessment-hash (buff 32)))
  (map-get? risk-assessments assessment-hash))

;; Get location risk profile
(define-read-only (get-location-risk-profile (location {latitude: int, longitude: int}))
  (map-get? location-risk-profiles location))

;; Get event type risk profile
(define-read-only (get-event-type-risk-profile (event-type (string-ascii 50)))
  (map-get? event-type-risks event-type))

;; Get historical risk data
(define-read-only (get-historical-risk-data (location {latitude: int, longitude: int}) (year uint))
  (map-get? historical-risk-events {location: location, year: year}))

;; Calculate quick risk score for pricing
(define-read-only (calculate-quick-risk-score
  (event-type (string-ascii 50))
  (location {latitude: int, longitude: int})
  (event-date uint))
  (let ((weather-risk (calculate-weather-risk location event-date))
        (location-risk (calculate-location-risk location))
        (event-type-risk (calculate-event-type-risk event-type)))
    (/ (+ (* weather-risk u40) (* location-risk u35) (* event-type-risk u25)) u100)))

;; Get risk factor configuration
(define-read-only (get-risk-factor-config (factor-name (string-ascii 30)))
  (map-get? risk-factors factor-name))

;; Private Functions

;; Calculate weather-based risk
(define-private (calculate-weather-risk (location {latitude: int, longitude: int}) (event-date uint))
  (let ((location-profile (map-get? location-risk-profiles location))
        (seasonal-month (get-month-from-timestamp event-date)))
    (match location-profile
      profile (let ((seasonal-score (unwrap! (element-at (get seasonal-patterns profile) seasonal-month) u100))
                    (base-weather-risk (get weather-risk-score profile)))
                (/ (+ base-weather-risk seasonal-score) u2))
      u100))) ;; Default risk if no profile

;; Calculate location-based risk
(define-private (calculate-location-risk (location {latitude: int, longitude: int}))
  (match (map-get? location-risk-profiles location)
    profile (/ (+ (get natural-disaster-risk profile) (get infrastructure-risk profile)) u2)
    u100)) ;; Default risk

;; Calculate timing-based risk
(define-private (calculate-timing-risk (event-date uint) (advance-booking-days uint))
  (let ((time-until-event (- event-date block-height))
        (booking-risk (if (< advance-booking-days u30) u120 u90)))
    (if (< time-until-event u1440) ;; Less than 1 day
        u200
        (if (< time-until-event u10080) ;; Less than 1 week
            u150
            booking-risk))))

;; Calculate event type risk
(define-private (calculate-event-type-risk (event-type (string-ascii 50)))
  (match (map-get? event-type-risks event-type)
    risk-profile (get base-risk-multiplier risk-profile)
    u100)) ;; Default risk

;; Calculate duration-based risk
(define-private (calculate-duration-risk (duration uint))
  (if (> duration u3) ;; More than 3 days
      u130
      (if (> duration u1) ;; More than 1 day
          u110
          u100)))

;; Calculate attendance-based risk
(define-private (calculate-attendance-risk (attendance uint))
  (if (> attendance u10000) ;; Large events
      u120
      (if (> attendance u1000)
          u110
          u100)))

;; Calculate weighted overall risk score
(define-private (calculate-weighted-risk-score
  (weather uint) (location uint) (timing uint)
  (event-type uint) (duration uint) (attendance uint))
  (/ (+ (* weather u25) (* location u20) (* timing u20)
        (* event-type u20) (* duration u10) (* attendance u5)) u100))

;; Convert risk score to premium multiplier
(define-private (risk-score-to-premium-multiplier (risk-score uint))
  (if (> risk-score u150)
      u200 ;; 2x premium for high risk
      (if (> risk-score u120)
          u150 ;; 1.5x premium for medium-high risk
          (if (> risk-score u80)
              u100 ;; Standard premium
              u80)))) ;; 0.8x premium for low risk

;; Generate assessment hash
(define-private (generate-assessment-hash
  (event-type (string-ascii 50))
  (location {latitude: int, longitude: int})
  (event-date uint))
  (keccak256 (concat (concat (unwrap-panic (to-consensus-buff? event-type))
                             (unwrap-panic (to-consensus-buff? location)))
                     (unwrap-panic (to-consensus-buff? event-date)))))

;; Get month from timestamp (simplified)
(define-private (get-month-from-timestamp (timestamp uint))
  (mod (/ timestamp u43200) u12)) ;; Simplified month calculation

;; Validate coordinates
(define-private (is-valid-coordinates (location {latitude: int, longitude: int}))
  (and
    (>= (get latitude location) -90000000)
    (<= (get latitude location) 90000000)
    (>= (get longitude location) -180000000)
    (<= (get longitude location) 180000000)))
