;; Clarity Smart Contract for Digital Badges in Online Education
;; This contract represents a non-fungible token (NFT) system for managing digital badges.
;; It is designed to handle the issuance, transfer, updating, and burning of badges awarded to students
;; for completing various milestones or courses in an online education platform.
;; Each badge is tied to a unique identifier (badge ID) and associated with metadata represented by a URI.

;; Constants for error codes and maximum URI length. These constants help to standardize error handling in the contract.
(define-constant err-owner-only (err u100))               ;; Error if the caller is not the badge owner
(define-constant err-not-badge-owner (err u101))          ;; Error if the caller is not the badge owner
(define-constant err-badge-exists (err u102))             ;; Error if the badge already exists
(define-constant err-badge-not-found (err u103))          ;; Error if the badge cannot be found
(define-constant err-invalid-uri (err u104))              ;; Error if the URI provided is invalid
(define-constant err-already-burned (err u105))           ;; Error if the badge has already been burned
(define-constant max-uri-length u256)                     ;; Maximum allowed length for URI

;; Data Variables
(define-non-fungible-token digital-badge uint)            ;; NFT token representing unique badges
(define-data-var last-badge-id uint u0)                   ;; Tracks the latest badge ID issued

;; Maps to store badge URIs and burned badge status.
(define-map badge-uri uint (string-ascii 256))            ;; Map badge ID to its URI (metadata of the badge)
(define-map burned-badges uint bool)                      ;; Track if a badge has been burned (revoked)

;; New map for reverse lookups: URI to badge ID
(define-map reverse-uri-map (string-ascii 256) uint)

;; Private Helper Functions

;; Checks if a URI is valid by confirming its length is within the allowed range.
;; Returns true if valid, false otherwise.
(define-private (is-valid-uri (uri (string-ascii 256)))
    (let ((uri-length (len uri)))
        (and (>= uri-length u1) (<= uri-length max-uri-length))))

;; Verifies whether the sender is the owner of the specified badge.
;; Returns true if the sender owns the badge, false otherwise.
(define-private (is-badge-owner (badge-id uint) (sender principal))
    (is-eq sender (unwrap! (nft-get-owner? digital-badge badge-id) false)))

;; Checks if a badge is burned by looking it up in the burned-badges map.
;; Returns true if burned, false otherwise.
(define-private (is-badge-burned (badge-id uint))
    (default-to false (map-get? burned-badges badge-id)))

;; Creates a single badge, assigning it a unique ID and URI.
;; Increments the last-badge-id variable and associates the URI with the new badge ID.
;; Returns the badge ID upon successful creation.
(define-private (create-single-badge (badge-uri-data (string-ascii 256)))
    (let ((badge-id (+ (var-get last-badge-id) u1)))
        (asserts! (is-valid-uri badge-uri-data) err-invalid-uri) ;; Check URI validity
        (try! (nft-mint? digital-badge badge-id tx-sender))      ;; Mint the badge NFT
        (map-set badge-uri badge-id badge-uri-data)              ;; Store the badge URI (metadata)
        (var-set last-badge-id badge-id)                         ;; Update the last badge ID issued
        (ok badge-id)))                                          ;; Return the badge ID created

;; Public Functions

;; Mints a new badge with the specified URI, which should contain metadata about the course or achievement.
;; Validates the URI before calling create-single-badge to mint the badge.
;; Returns the badge ID of the newly created badge.
(define-public (mint-badge (uri (string-ascii 256)))
    (begin
        (asserts! (is-valid-uri uri) err-invalid-uri)    ;; Validate URI length
        (create-single-badge uri)))                      ;; Create the badge and return its ID

;; Mints multiple badges in a single transaction, with a maximum of 100 badges in one batch.
;; Each URI is validated, and batch minting is handled through a fold operation.
;; Returns a list of badge IDs for all badges created in the batch.
(define-public (batch-mint-badges (uris (list 100 (string-ascii 256))))
    (let ((batch-size (len uris)))
        (begin
            (asserts! (<= batch-size u100) (err u108)) ;; Check if the batch size is within the allowed limit (100)
            (ok (fold mint-single-in-batch uris (list))) ;; Mint badges for each URI in the batch
        )))

;; Helper function for batch minting: mints a single badge within a batch operation.
;; Appends the new badge ID to the list of results, ensuring the batch size remains within the limit.
(define-private (mint-single-in-batch (uri (string-ascii 256)) (previous-results (list 100 uint)))
    (match (create-single-badge uri)
        success (unwrap-panic (as-max-len? (append previous-results success) u100))
        error previous-results))

;; Burns (deletes) a badge by its ID, making it non-transferable and non-viewable.
;; Only the badge owner can burn their badge, and it must not have been burned before.
;; Marks the badge as burned and returns true if successful.
(define-public (burn-badge (badge-id uint))
    (let ((badge-owner (unwrap! (nft-get-owner? digital-badge badge-id) err-badge-not-found)))
        (asserts! (is-eq tx-sender badge-owner) err-not-badge-owner) ;; Check if the sender is the owner of the badge
        (asserts! (not (is-badge-burned badge-id)) err-already-burned) ;; Ensure the badge has not been burned already
        (let ((uri (unwrap-panic (map-get? badge-uri badge-id))))
            (try! (nft-burn? digital-badge badge-id badge-owner))
            (map-set burned-badges badge-id true)
            (map-delete reverse-uri-map uri))                   ;; Remove reverse mapping on burn
        (ok true)))


;; Transfers a badge from the sender to a recipient.
;; Ensures the sender owns the badge, the badge is not burned, and it is successfully transferred to the recipient.
(define-public (transfer-badge (badge-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq recipient tx-sender) err-not-badge-owner) ;; Ensure the recipient is the tx-sender
        (asserts! (not (is-badge-burned badge-id)) err-already-burned) ;; Check if the badge has not been burned
        (let ((actual-sender (unwrap! (nft-get-owner? digital-badge badge-id) err-not-badge-owner)))
            (asserts! (is-eq actual-sender sender) err-not-badge-owner) ;; Verify actual ownership of the badge
            (try! (nft-transfer? digital-badge badge-id sender recipient)) ;; Transfer the badge NFT
            (ok true))))                                               ;; Return success

;; Updates the URI of a badge.
;; Only the badge owner can update the URI, and the URI must be valid.
(define-public (update-badge-uri (badge-id uint) (new-uri (string-ascii 256)))
    (let ((badge-owner (unwrap! (nft-get-owner? digital-badge badge-id) err-badge-not-found)))
        (asserts! (is-eq badge-owner tx-sender) err-not-badge-owner)
        (asserts! (is-valid-uri new-uri) err-invalid-uri)
        (let ((old-uri (unwrap-panic (map-get? badge-uri badge-id))))
            (map-delete reverse-uri-map old-uri)               ;; Remove old URI mapping
            (map-set badge-uri badge-id new-uri)               ;; Update badge URI
            (map-set reverse-uri-map new-uri badge-id))        ;; Add new URI mapping
        (ok true)))

;; Read-Only Functions

;; Retrieves the URI associated with a specific badge ID, which contains the badge's metadata (course info, etc.)
;; Returns the URI or an option type if the badge ID does not exist.
(define-read-only (get-badge-uri (badge-id uint))
    (ok (map-get? badge-uri badge-id)))

;; Returns the owner of a badge by its ID, if it exists. This is used to check who owns a particular badge.
(define-read-only (get-owner (badge-id uint))
    (ok (nft-get-owner? digital-badge badge-id)))

;; Returns the ID of the last badge created, helping to track the most recent badge issued.
(define-read-only (get-last-badge-id)
    (ok (var-get last-badge-id)))

;; Checks if a specific badge has been burned. This is useful to verify if a badge has been revoked.
;; Returns true if burned, false otherwise.
(define-read-only (is-burned (badge-id uint))
    (ok (is-badge-burned badge-id)))
    
;; New Read-Only Function: Search for Badge by URI
(define-read-only (search-badge-by-uri (uri (string-ascii 256)))
    (ok (map-get? reverse-uri-map uri)))    

