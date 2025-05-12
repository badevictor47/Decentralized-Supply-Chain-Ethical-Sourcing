;; supplier-verification.clar
;; Validates vendors in the supply chain

(define-data-var last-supplier-id uint u0)

(define-map suppliers
  { supplier-id: uint }
  {
    name: (string-ascii 100),
    address: (string-ascii 100),
    verified: bool,
    verification-date: uint,
    verifier: principal
  }
)

(define-public (register-supplier (name (string-ascii 100)) (address (string-ascii 100)))
  (let
    (
      (new-id (+ (var-get last-supplier-id) u1))
    )
    (var-set last-supplier-id new-id)
    (map-set suppliers
      { supplier-id: new-id }
      {
        name: name,
        address: address,
        verified: false,
        verification-date: u0,
        verifier: tx-sender
      }
    )
    (ok new-id)
  )
)

(define-public (verify-supplier (supplier-id uint))
  (let
    (
      (supplier (unwrap! (map-get? suppliers { supplier-id: supplier-id }) (err u404)))
    )
    (map-set suppliers
      { supplier-id: supplier-id }
      (merge supplier {
        verified: true,
        verification-date: block-height,
        verifier: tx-sender
      })
    )
    (ok true)
  )
)

(define-read-only (get-supplier (supplier-id uint))
  (map-get? suppliers { supplier-id: supplier-id })
)

(define-read-only (is-supplier-verified (supplier-id uint))
  (default-to false (get verified (map-get? suppliers { supplier-id: supplier-id })))
)
