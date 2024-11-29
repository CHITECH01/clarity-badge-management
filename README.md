# Badge NFT Manager

## Overview

The **Badge NFT Manager** is a Clarity smart contract designed for managing digital badges within an online education platform. These badges are represented as Non-Fungible Tokens (NFTs), which are unique, transferable, and associated with metadata in the form of a URI. The contract allows minting, transferring, updating, burning, and retrieving badge data. 

Each badge is:
- Uniquely identified by a badge ID
- Associated with metadata (URI)
- Transferable between users
- Updateable and revocable (burnable)

This contract serves as a foundational component for managing achievements in a gamified education environment, awarding digital badges for accomplishments.

---

## Key Features

- **Minting Badges**: Issue badges individually or in batches.
- **Ownership Verification**: Ensure that only the rightful owner can update, burn, or transfer a badge.
- **Metadata Updates**: Update or change the URI linked to a badge's metadata.
- **Burning Badges**: Revoking or "burning" a badge to signify its invalidation.
- **Transfer of Ownership**: Badge ownership can be transferred between users.
- **Reverse URI Lookup**: Lookup badge IDs by metadata URI.
- **Tracking Badges**: Tracks the total number of badges minted.

---

## Contract Details

### Error Codes & Limits

| Error Code            | Description                                             |
|-----------------------|---------------------------------------------------------|
| `err-not-owner`        | Caller is not the badge owner.                         |
| `err-not-badge-owner`  | Badge ownership mismatch.                              |
| `err-badge-exists`     | Badge already exists.                                  |
| `err-badge-not-found`  | Badge not found.                                        |
| `err-invalid-uri`      | Invalid URI provided.                                  |
| `err-already-burned`   | Badge is already burned.                               |
| `max-uri-length`       | Maximum allowed URI length (256 characters).           |

### NFT Definition & State

- **`digital-badge`**: A Non-Fungible Token (NFT) representing the badge. Each badge has a unique ID (`uint`).
- **`last-badge-id`**: Tracks the ID of the most recently minted badge.
- **`total-badges-minted`**: Tracks the total number of badges minted.
- **`badge-uri`**: A map that links badge IDs to metadata URIs.
- **`burned-badges`**: A map that tracks burned (revoked) badges.
- **`reverse-uri-map`**: A reverse lookup map that allows you to search for badge IDs by metadata URI.

---

## Functions

### Public Functions

- **`mint-badge(uri)`**: Mint a new badge with a specified URI.
- **`batch-mint-badges(uris)`**: Mint multiple badges in a single transaction (max: 100 badges).
- **`burn-badge(badge-id)`**: Burn (revoke) a badge by its ID. Only the owner can burn it.
- **`transfer-badge(badge-id, sender, recipient)`**: Transfer badge ownership to another user.
- **`update-badge-uri(badge-id, new-uri)`**: Update the metadata URI of a badge. Only the owner can update it.

### Read-Only Functions

- **`get-badge-uri(badge-id)`**: Retrieve the metadata URI for a given badge ID.
- **`get-owner(badge-id)`**: Retrieve the owner of a badge by its ID.
- **`get-last-badge-id()`**: Get the most recently issued badge ID.
- **`is-burned(badge-id)`**: Check if a badge has been burned.
- **`search-badge-by-uri(uri)`**: Search for a badge by its URI.
- **`get-total-badges-minted()`**: Retrieve the total number of badges minted.

---

## Contract Logic

### Minting a Badge

To mint a badge, a user submits a URI for the badge's metadata. The system creates a new badge with a unique ID, associates the URI with it, and mints it as an NFT. 

- The function **`mint-badge`** mints a single badge.
- The function **`batch-mint-badges`** allows minting multiple badges in one transaction, up to a limit of 100 badges.

### Burning a Badge

A badge can be burned (revoked) by the badge owner. Once a badge is burned, it cannot be recovered.

- The function **`burn-badge`** allows the owner of a badge to burn it, revoking the badge and removing its URI from the system.

### Transferring Ownership

Badges can be transferred between users. The badge owner can transfer the badge to a recipient, and the contract verifies ownership before allowing the transfer.

- The function **`transfer-badge`** enables the owner of a badge to transfer it to a new owner.

### URI Updates

Badges are associated with a metadata URI, which can be updated by the badge owner. This allows for dynamic changes to the badge's associated content.

- The function **`update-badge-uri`** allows the owner of a badge to update its metadata URI.

---

## Contract Usage Example

### Mint a Badge

```clarity
(mint-badge "https://example.com/badge/1")
```

### Mint Multiple Badges

```clarity
(batch-mint-badges ["https://example.com/badge/1" "https://example.com/badge/2" ...])
```

### Burn a Badge

```clarity
(burn-badge 1)
```

### Transfer a Badge

```clarity
(transfer-badge 1 "sender-principal" "recipient-principal")
```

### Update Badge URI

```clarity
(update-badge-uri 1 "https://new-url.com/badge/1")
```

### Get Badge URI

```clarity
(get-badge-uri 1)
```

---

## Contract Development Notes

This contract is designed with educational platforms in mind, where badges represent achievements such as completing courses, reaching milestones, or excelling in a particular skill. The use of NFTs ensures that badges are unique, verifiable, and tamper-proof.

---

## License

This contract is licensed under the [MIT License](https://opensource.org/licenses/MIT).
```

This README provides a comprehensive overview of the smart contract, including:

- The contract's purpose and key features.
- Detailed explanations of public and read-only functions.
- Example usage for each function.
- Development notes and contract logic.

You can adjust the "License" section based on your desired licensing terms.