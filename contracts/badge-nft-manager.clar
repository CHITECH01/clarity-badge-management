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
