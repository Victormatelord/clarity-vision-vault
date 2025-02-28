;; VisionVault - Personal Knowledge Library Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-not-authorized (err u401))
(define-constant err-invalid-input (err u400))

;; Data structures
(define-map content-items 
  { content-id: uint }
  {
    url: (string-utf8 256),
    title: (string-utf8 100),
    content-type: (string-ascii 20),
    description: (string-utf8 500),
    owner: principal,
    created-at: uint
  }
)

(define-map collections
  { collection-id: uint }
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    owner: principal,
    created-at: uint,
    shared-with: (list 10 principal)
  }
)

(define-map collection-contents
  { collection-id: uint }
  { content-ids: (list 100 uint) }
)

;; Data variables
(define-data-var content-id-counter uint u0)
(define-data-var collection-id-counter uint u0)

;; Content management functions
(define-public (save-content (url (string-utf8 256)) 
                           (title (string-utf8 100))
                           (content-type (string-ascii 20))
                           (description (string-utf8 500)))
  (let ((new-id (+ (var-get content-id-counter) u1)))
    (try! (validate-content url title content-type))
    (map-set content-items
      { content-id: new-id }
      {
        url: url,
        title: title,
        content-type: content-type,
        description: description,
        owner: tx-sender,
        created-at: block-height
      }
    )
    (var-set content-id-counter new-id)
    (ok new-id)
  )
)

;; Collection management functions
(define-public (create-collection (name (string-utf8 100)) (description (string-utf8 500)))
  (let ((new-id (+ (var-get collection-id-counter) u1)))
    (map-set collections
      { collection-id: new-id }
      {
        name: name,
        description: description,
        owner: tx-sender,
        created-at: block-height,
        shared-with: (list)
      }
    )
    (map-set collection-contents
      { collection-id: new-id }
      { content-ids: (list) }
    )
    (var-set collection-id-counter new-id)
    (ok new-id)
  )
)

(define-public (add-to-collection (content-id uint) (collection-id uint))
  (let ((collection (unwrap! (get-collection collection-id) err-not-found))
        (content (unwrap! (get-content content-id) err-not-found)))
    (asserts! (or (is-eq tx-sender (get owner collection))
                 (is-some (index-of (get shared-with collection) tx-sender)))
             err-not-authorized)
    (let ((current-contents (unwrap! (map-get? collection-contents { collection-id: collection-id }) err-not-found)))
      (map-set collection-contents
        { collection-id: collection-id }
        { content-ids: (append (get content-ids current-contents) content-id) }
      )
      (ok true)
    )
  )
)

(define-public (share-collection (collection-id uint) (user principal))
  (let ((collection (unwrap! (get-collection collection-id) err-not-found)))
    (asserts! (is-eq tx-sender (get owner collection)) err-not-authorized)
    (let ((current-shared (get shared-with collection)))
      (map-set collections
        { collection-id: collection-id }
        (merge collection { shared-with: (append current-shared user) })
      )
      (ok true)
    )
  )
)

;; Helper functions
(define-private (validate-content (url (string-utf8 256)) 
                                (title (string-utf8 100))
                                (content-type (string-ascii 20)))
  (if (and (> (len url) u0)
           (> (len title) u0)
           (asserts! (or (is-eq content-type "article")
                       (is-eq content-type "video")
                       (is-eq content-type "tutorial")) 
                   err-invalid-input))
      (ok true)
      err-invalid-input)
)

(define-read-only (get-content (content-id uint))
  (map-get? content-items { content-id: content-id })
)

(define-read-only (get-collection (collection-id uint))
  (map-get? collections { collection-id: collection-id })
)
