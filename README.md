# Serverless Image Management Platform

A comprehensive serverless web application built on AWS that provides secure image upload, storage, and management capabilities with role-based access control and embedded authentication.

## 🏗️ Architecture Overview

This application leverages a fully serverless architecture on AWS, utilizing Infrastructure as Code (Terraform) for deployment and management. The system is designed for scalability, security, and cost-effectiveness.

### Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   API Gateway   │    │   Lambda        │
│   (S3 Static)   │────│   (REST API)    │────│   Functions     │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Amazon        │    │   Amazon        │    │   Amazon S3     │
│   Cognito       │    │   DynamoDB      │    │   (Photo        │
│   (Auth)        │    │   (Metadata)    │    │   Storage)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ Technology Stack

### Frontend

- **HTML5/CSS3/JavaScript**: Modern web standards
- **Bootstrap 5**: Responsive UI framework
- **AWS SDK**: Client-side AWS service integration
- **Amazon Cognito Identity SDK**: Authentication management

### Backend Services

- **AWS Lambda**: Serverless compute for business logic
- **Amazon API Gateway**: RESTful API management with CORS
- **Amazon Cognito**: User authentication and authorization
- **Amazon S3**: Static website hosting and image storage
- **Amazon DynamoDB**: NoSQL database for metadata storage

### Infrastructure

- **Terraform**: Infrastructure as Code (IaC)
- **AWS Provider**: Cloud resource management

## 🔧 Components

### 1. Frontend Application (`html/`)

- **Static Website**: Hosted on S3 with CloudFront-ready configuration
- **Responsive Design**: Mobile-first approach with Bootstrap
- **Embedded Authentication**: Custom login/register modals (no redirect)
- **Real-time Updates**: Dynamic photo gallery with role-based filtering

### 2. Authentication System (`cognito.tf`)

- **User Pool**: Centralized user management
- **Custom Attributes**: Role-based access control (admin, manager, staff, customer)
- **Password Policies**: Enforced security standards
- **Email Verification**: Automated account confirmation

### 3. API Layer (`api-gateway.tf`)

- **RESTful Endpoints**: `/photos` resource with GET/POST methods
- **CORS Configuration**: Cross-origin resource sharing enabled
- **Cognito Authorization**: JWT token validation
- **Request/Response Transformation**: Standardized API responses

### 4. Business Logic (`lambda_functions/`)

#### Upload Photo Lambda (`upload_photo.py`)

- **Base64 Processing**: Client-side file encoding
- **S3 Integration**: Secure file storage with metadata
- **DynamoDB Logging**: Photo metadata persistence
- **Presigned URLs**: Secure file access

#### Get Photos Lambda (`get_photos.py`)

- **Role-based Filtering**: Users see own photos, admins see all
- **Metadata Retrieval**: Efficient DynamoDB queries
- **Presigned URL Generation**: Secure, time-limited access
- **Response Optimization**: Sorted by upload date

### 5. Data Storage

#### S3 Buckets

- **Static Website Bucket**: Frontend application hosting
- **Photo Storage Bucket**: Encrypted image storage with versioning
- **Organized Structure**: User-based folder hierarchy

#### DynamoDB Tables

- **Photo Metadata Table**:
  - Primary Key: `photo_id`
  - GSI: `user_id` + `uploaded_at` for efficient querying
  - Attributes: file metadata, user info, descriptions

## 🔐 Security Features

### Authentication & Authorization

- **JWT Tokens**: Secure session management
- **Role-based Access Control**: Granular permissions
- **Token Validation**: API Gateway Cognito authorizer

### Data Security

- **S3 Encryption**: Server-side encryption at rest
- **HTTPS Enforcement**: All traffic encrypted in transit
- **Presigned URLs**: Time-limited, secure file access
- **CORS Policies**: Controlled cross-origin requests

### Infrastructure Security

- **IAM Roles**: Least privilege principle
- **VPC Integration**: Network isolation ready
- **CloudTrail Ready**: Audit logging capabilities

## 📁 Project Structure

```
├── main.tf                 # Provider configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output values
├── cognito.tf             # Authentication infrastructure
├── api-gateway.tf         # API management
├── lambda.tf              # Serverless functions & storage
├── bucket.tf              # Static website hosting
├── html/                  # Frontend application
│   ├── index.html         # Main application page
│   ├── index.js           # Core JavaScript logic
│   ├── style.css          # Custom styling
│   ├── config.js.template # Dynamic configuration
│   └── error.html         # Error page
└── lambda_functions/      # Backend logic
    ├── upload_photo.py    # Photo upload handler
    └── get_photos.py      # Photo retrieval handler
```

## 🚀 Deployment

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Python 3.9+ (for Lambda functions)

### Infrastructure Deployment

1. **Initialize Terraform**

   ```bash
   terraform init
   ```

2. **Plan Deployment**

   ```bash
   terraform plan
   ```

3. **Deploy Infrastructure**

   ```bash
   terraform apply
   ```

4. **Access Application**

   ```bash
   # Get website URL
   terraform output website_url

   # Get API Gateway URL
   terraform output api_gateway_url
   ```

### Configuration Management

- **Dynamic Configuration**: Terraform generates `config.js` with actual resource IDs
- **Environment Variables**: Lambda functions use Terraform-managed environment variables
- **State Management**: Terraform state tracks all resources

## 🎯 Key Features

### User Experience

- **Embedded Authentication**: No external redirects
- **Drag & Drop Upload**: Intuitive file handling
- **Real-time Preview**: Instant image preview
- **Responsive Design**: Works on all devices
- **Role-based UI**: Dynamic interface based on user permissions

### Administrative Features

- **User Management**: View all users and photos (admin only)
- **Statistics Dashboard**: Photo counts and user analytics
- **Bulk Operations**: Administrative photo management

### Technical Features

- **Auto-scaling**: Serverless components scale automatically
- **Cost Optimization**: Pay-per-use pricing model
- **High Availability**: Multi-AZ deployment ready
- **Monitoring Ready**: CloudWatch integration

## 🔧 Configuration

### Environment Variables

- `PHOTO_BUCKET`: S3 bucket for photo storage
- `PHOTO_TABLE`: DynamoDB table for metadata
- `COGNITO_*`: Authentication configuration

### Customization Options

- **Role Definitions**: Modify user roles in Cognito configuration
- **File Restrictions**: Adjust file types and sizes in frontend
- **UI Themes**: Customize Bootstrap variables in CSS
- **API Endpoints**: Extend API Gateway for additional features

## 📊 Monitoring & Maintenance

### Logging

- **CloudWatch Logs**: Lambda function execution logs
- **API Gateway Logs**: Request/response logging
- **S3 Access Logs**: File access tracking

### Metrics

- **Lambda Metrics**: Execution duration, errors, invocations
- **API Gateway Metrics**: Request counts, latencies, errors
- **Cognito Metrics**: Authentication attempts, user registrations

## 🔄 CI/CD Ready

The infrastructure is designed for continuous integration and deployment:

- **Terraform State**: Remote state management ready
- **Modular Design**: Easy to extend and modify
- **Version Control**: All code and infrastructure versioned
- **Automated Testing**: Integration test framework ready

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For support and questions:

- Create an issue in the repository
- Review the Terraform documentation
- Check AWS service documentation

---

**Built with ❤️ using AWS Serverless Technologies**
