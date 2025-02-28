# VisionVault
A decentralized personal knowledge library for organizing and saving articles, videos, and tutorials.

## Features
- Save content items (articles, videos, tutorials) with metadata
- Organize content into collections
- Share collections with other users
- Search saved content
- Track view/access history

## Setup and Installation
1. Clone the repository
2. Install Clarinet (if not already installed)
3. Run `clarinet check` to verify the contract
4. Run `clarinet test` to run the test suite

## Usage Examples
```clarity
;; Save new content item
(contract-call? .vision-vault save-content "https://example.com/article" "My Article" "article" "Description here")

;; Create new collection
(contract-call? .vision-vault create-collection "My Learning Collection" "Tech tutorials")

;; Add content to collection
(contract-call? .vision-vault add-to-collection u1 u1)

;; Share collection
(contract-call? .vision-vault share-collection u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
