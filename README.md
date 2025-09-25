# 💰 Innovation Bounty Marketplace

[![Clarinet](https://img.shields.io/badge/Clarinet-v3-blue)](https://github.com/hirosystems/clarinet)
[![Stacks](https://img.shields.io/badge/Stacks-2.5-orange)](https://www.stacks.co/)
[![Smart Contract](https://img.shields.io/badge/Smart%20Contract-409%20lines-green)](#)

## 🚀 Overview

A decentralized marketplace built on Stacks blockchain where innovators can post bounties for technical challenges and skilled developers can submit solutions to earn rewards. The platform features expert review systems, hunter profiles, and transparent reward distribution.

## ✨ Key Features

### 🎯 Bounty Creation
- Create innovation bounties with custom reward amounts
- Set deadlines and required skill categories
- Automatic escrow of bounty funds
- Community funding for increased rewards

### 🏆 Solution Submission
- Submit solutions with GitHub repos and demo links
- Track submission status and review scores
- Build hunter reputation through successful completions
- Skill-based matching system

### 👨‍💼 Expert Review System
- Assign qualified reviewers with domain expertise
- Score-based evaluation (0-100)
- Winner selection with automated payouts
- Transparent review process

### 📊 Hunter Profiles
- Track submissions, wins, and earnings
- Build reputation scores and success rates
- Showcase skill tags and expertise areas
- Performance-based profile enhancement

### 💵 Funding & Economics
- Secure fund escrow system
- 3% platform fee (configurable)
- Community funding support
- Automatic reward distribution

## 🏗️ Smart Contract Architecture

### Core Components
- **Bounties**: Innovation challenges with rewards and requirements
- **Submissions**: Solution proposals with links and descriptions
- **Reviews**: Expert evaluation and scoring system
- **Hunter Profiles**: Developer reputation and skill tracking
- **Funding**: Community support and reward management

### Status Management
- **Bounty Status**: Active → Under Review → Completed/Cancelled
- **Submission Status**: Pending → Accepted/Rejected
- **Review Status**: Pending → Approved/Rejected

## 🚀 Quick Start

### Prerequisites
- [Clarinet CLI](https://github.com/hirosystems/clarinet) v3.0+
- Stacks wallet with STX tokens
- Development environment setup

### Installation
```bash
git clone https://github.com/yourusername/Innovation-Bounty-Marketplace.git
cd Innovation-Bounty-Marketplace
clarinet check
clarinet test
```

## 💻 Usage Examples

### Create a Bounty
```clarity
(contract-call? .innovation-bounty-marketplace create-bounty
  "Build DeFi Analytics Dashboard"
  "Create a comprehensive analytics dashboard for DeFi protocols with real-time data visualization and portfolio tracking features"
  "defi"
  u100000              ;; 100,000 microSTX reward
  u2880               ;; 2880 blocks (~20 days)
  (list "javascript" "react" "web3" "analytics")  ;; required skills
)
```

### Submit Solution
```clarity
(contract-call? .innovation-bounty-marketplace submit-solution
  u1                   ;; bounty-id
  "DeFi Analytics Pro"
  "A React-based dashboard with Web3 integration, real-time price feeds, and portfolio analytics"
  "https://github.com/developer/defi-analytics"
  "https://defi-analytics-demo.vercel.app"
)
```

### Assign Reviewer
```clarity
(contract-call? .innovation-bounty-marketplace assign-reviewer
  u1                   ;; bounty-id
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7  ;; reviewer principal
  (list "defi" "frontend" "web3")               ;; expertise areas
)
```

### Review Submission
```clarity
(contract-call? .innovation-bounty-marketplace review-submission
  u1          ;; submission-id
  u85         ;; review score (0-100)
  true        ;; is-winner
)
```

### Fund Bounty
```clarity
(contract-call? .innovation-bounty-marketplace fund-bounty
  u1          ;; bounty-id
  u25000      ;; additional 25,000 microSTX
)
```

### Update Hunter Skills
```clarity
(contract-call? .innovation-bounty-marketplace update-hunter-skills
  'SP1HTBVD3JG9C05J7HDJKDYR7K0VN7N1C3V3P9Q  ;; hunter principal
  (list "solidity" "rust" "javascript" "defi" "nft")  ;; skill tags
)
```

## 📚 API Reference

### Public Functions

#### Bounty Management
- `create-bounty(title, description, category, reward-amount, duration-blocks, required-skills)` - Create new bounty
- `fund-bounty(bounty-id, amount)` - Add funding to existing bounty
- `cancel-bounty(bounty-id)` - Cancel bounty and refund creator

#### Solution System
- `submit-solution(bounty-id, title, description, github-link, demo-link)` - Submit solution
- `assign-reviewer(bounty-id, reviewer, expertise-areas)` - Assign expert reviewer
- `review-submission(submission-id, review-score, is-winner)` - Review and score submission

#### Profile Management
- `update-hunter-skills(hunter, skill-tags)` - Update skill profile

#### Platform Administration
- `set-platform-fee(new-fee)` - Update platform fee (max 10%)
- `set-min-bounty-amount(new-amount)` - Set minimum bounty requirement

### Read-Only Functions
- `get-bounty(bounty-id)` - Retrieve bounty details
- `get-submission(submission-id)` - Get submission information
- `get-hunter-profile(hunter)` - View hunter statistics
- `get-bounty-review(bounty-id, reviewer)` - Review assignment details
- `get-bounty-funding(bounty-id, backer)` - Funding information
- `get-platform-stats()` - Platform-wide statistics

### Error Codes
- `u400` - Invalid input parameters
- `u401` - Unauthorized access
- `u402` - Insufficient funds
- `u403` - Bounty closed
- `u404` - Bounty not found
- `u405` - Submission not found
- `u406` - Already submitted/assigned
- `u407` - Deadline passed
- `u408` - Invalid status
- `u409` - Not authorized reviewer
- `u410` - Already reviewed

## 🎯 Platform Economics

### Reward Distribution
- **Winner**: ~97% of bounty pool (minus platform fee)
- **Platform Fee**: 3% (configurable up to 10%)
- **Minimum Bounty**: 5,000 microSTX

### Hunter Reputation
- **+25 points** per bounty won
- **Success rate** calculated from wins/submissions
- **Skill tags** for expertise showcase
- **Total earnings** tracking

### Funding Model
- Initial bounty funding by creator
- Optional community funding support
- Secure escrow until completion
- Automatic distribution to winners

## 🔒 Security Features

### Access Control
- Only bounty creators can assign reviewers
- Only assigned reviewers can evaluate submissions
- Hunters control their own skill profiles
- Platform owner manages fee settings

### Fund Safety
- All bounty funds held in contract escrow
- Automatic winner payouts upon review completion
- Refund mechanism for cancelled bounties
- Platform fee collection on successful completion

### Review Integrity
- One reviewer per bounty assignment
- Prevent duplicate reviews
- Score validation (0-100 range)
- Status-based operation controls

## 🧪 Testing

### Run Tests
```bash
clarinet test
clarinet console
```

### Test Scenarios
- Bounty creation with various parameters
- Solution submission and validation
- Reviewer assignment and evaluation
- Funding mechanics and distribution
- Profile management and updates
- Error handling and edge cases

## 🌟 Use Cases

### 🏢 Corporate Innovation
- Internal hackathons and challenges
- Product feature development bounties
- Technical problem-solving contests
- Employee skill development programs

### 🎓 Educational Platforms
- Coding bootcamp final projects
- University research challenges
- Student portfolio development
- Peer-to-peer learning incentives

### 🌍 Open Source Projects
- Feature implementation bounties
- Bug fixing rewards
- Documentation improvements
- Community contribution incentives

### 💼 Freelance Development
- Project-based development work
- Technical consultation requests
- Proof-of-concept development
- Skills assessment challenges

## 🛠️ Development

### Local Development
```bash
clarinet console
clarinet integrate
```

### Contract Deployment
```bash
# Deploy to testnet
stx deploy_contract innovation-bounty-marketplace innovation-bounty-marketplace.clar --testnet

# Deploy to mainnet
stx deploy_contract innovation-bounty-marketplace innovation-bounty-marketplace.clar --mainnet
```

## 🤝 Contributing

### Development Setup
```bash
git clone <repository>
cd Innovation-Bounty-Marketplace
npm install
clarinet check
```

### Contribution Guidelines
- Follow Clarity best practices
- Include comprehensive tests
- Update documentation
- Consider security implications
- Test all edge cases

### Types of Contributions
- 🐛 Bug fixes and improvements
- ✨ New features and enhancements
- 📚 Documentation updates
- 🧪 Test coverage expansion
- 🔒 Security audits

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Stacks Foundation** for blockchain infrastructure
- **Clarinet Team** for development tools
- **Developer Community** for feedback and contributions
- **Innovation Ecosystem** for inspiration

---

**🚀 Ready to revolutionize innovation bounties on the blockchain!**

*Built with ❤️ for the developer community*
