;; certification.clar
;; Records authenticated ethical claims

(define-data-var last-certification-id uint u0)

(define-map certifications
  { certification-id: uint }
  {
    supplier-id: uint,
    standard-id: uint,
    issue-date: uint,
    expiry-date: uint,
    issuer: principal,
    active: bool,
    revocation-date: uint,
    revocation-reason: (string-ascii 255)
  }
)

(define-public (issue-certification (supplier-id uint) (standard-id uint) (expiry-date uint))
  (let
    (
      (new-id (+ (var-get last-certification-id) u1))
    )
    (var-set last-certification-id new-id)
    (map-set certifications
      { certification-id: new-id }
      {
        supplier-id: supplier-id,
        standard-id: standard-id,
        issue-date: block-height,
        expiry-date: expiry-date,
        issuer: tx-sender,
        active: true,
        revocation-date: u0,
        revocation-reason: ""
      }
    )
    (ok new-id)
  )
)

(define-public (revoke-certification (certification-id uint) (reason (string-ascii 255)))
  (let
    (
      (certification (unwrap! (map-get? certifications { certification-id: certification-id }) (err u404)))
    )
    (asserts! (is-eq (get issuer certification) tx-sender) (err u403))
    (map-set certifications
      { certification-id: certification-id }
      (merge certification {
        active: false,
        revocation-date: block-height,
        revocation-reason: reason
      })
    )
    (ok true)
  )
)

(define-read-only (get-certification (certification-id uint))
  (map-get? certifications { certification-id: certification-id })
)

(define-read-only (is-certification-valid (certification-id uint))
  (let
    (
      (certification (default-to
        {
          supplier-id: u0,
          standard-id: u0,
          issue-date: u0,
          expiry-date: u0,
          issuer: tx-sender,
          active: false,
          revocation-date: u0,
          revocation-reason: ""
        }
        (map-get? certifications { certification-id: certification-id })))
    )
    (and
      (get active certification)
      (< block-height (get expiry-date certification))
    )
  )
)
