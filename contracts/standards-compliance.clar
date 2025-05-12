;; standards-compliance.clar
;; Records ethical requirements for suppliers

(define-data-var last-standard-id uint u0)

(define-map standards
  { standard-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 255),
    created-at: uint,
    created-by: principal
  }
)

(define-map supplier-compliance
  { supplier-id: uint, standard-id: uint }
  {
    compliant: bool,
    compliance-date: uint,
    verifier: principal,
    evidence-hash: (buff 32)
  }
)

(define-public (create-standard (name (string-ascii 100)) (description (string-ascii 255)))
  (let
    (
      (new-id (+ (var-get last-standard-id) u1))
    )
    (var-set last-standard-id new-id)
    (map-set standards
      { standard-id: new-id }
      {
        name: name,
        description: description,
        created-at: block-height,
        created-by: tx-sender
      }
    )
    (ok new-id)
  )
)

(define-public (set-compliance (supplier-id uint) (standard-id uint) (compliant bool) (evidence-hash (buff 32)))
  (begin
    (map-set supplier-compliance
      { supplier-id: supplier-id, standard-id: standard-id }
      {
        compliant: compliant,
        compliance-date: block-height,
        verifier: tx-sender,
        evidence-hash: evidence-hash
      }
    )
    (ok true)
  )
)

(define-read-only (get-standard (standard-id uint))
  (map-get? standards { standard-id: standard-id })
)

(define-read-only (get-compliance (supplier-id uint) (standard-id uint))
  (map-get? supplier-compliance { supplier-id: supplier-id, standard-id: standard-id })
)

(define-read-only (is-compliant (supplier-id uint) (standard-id uint))
  (default-to false (get compliant (map-get? supplier-compliance { supplier-id: supplier-id, standard-id: standard-id })))
)
