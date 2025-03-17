# Mock-API

![Splash](docs/splash.png)

## Introduction

This is an example of how to use the [Dart language](https://dart.dev/) to quickly build a API mock server to use
while developing and testing an application.

## SimFin API

This application mocks part of the [SimFin website](https://www.simfin.com/en/) used to download bulk financial data as 
series of 89 zip files.  SimFin is a fintech start-up based in Halle, Germany, offering investors and analysts a 
stock market analysis platform with high-quality financial data and innovative tools.  The company offers several 
commercial plans and a free plan limited to 60 file downloads per 24 hours.  At the time of writing SimFin tell me that
the don't have a developers environment, hence the need to code up a mock server coding and testing purposes.

The production end point is located at: https://prod.simfin.com/api/bulk-download/s3 and accepts a combination of three
parameters to generate the downloadable data files as follows:

| DataSet            | Market     | Variant                  | Example File                        |
|--------------------|------------|--------------------------|-------------------------------------|
| markets            |            |                          | markets.zip                         |
| industries         |            |                          | industries.zip                      |
| companies          | us, de, cn |                          | us-companies.zip                    |
| shareprices        | us, de, cn | daily (there are others) | de-shareprices-daily.zip            |
| income             | us, de, cn | annual, quarterly, ttm   | us-income-annual.zip                |
| income-banks       | us, de, cn | annual, quarterly, ttm   | us-income-banks-annual.zip          |
| income-insurance   | us, de, cn | annual, quarterly, ttm   | us-income-insurance-quarterly.zip   |
| cashflow           | us, de, cn | annual, quarterly, ttm   | us-cashflow-annual.zip              |
| cashflow-banks     | us, de, cn | annual, quarterly, ttm   | us-cashflow-banks-annual.zip        |
| cashflow-insurance | us, de, cn | annual, quarterly, ttm   | us-cashflow-insurance-quarterly.zip |
| balance            | us, de, cn | annual, quarterly, ttm   | us-balance-annual.zip               |
| balance-banks      | us, de, cn | annual, quarterly, ttm   | us-balance-banks-annual.zip         |
| balance-insurance  | us, de, cn | annual, quarterly, ttm   | us-balance-insurance-quarterly.zip  |

In order to access this data you will need at a minimum to create a free account and obtain a key to be used in making 
the api call. 

## Operation

This mock server performs a very simple function.  It serves zip files from a folder (files) defined in the application's
config file (mock-api.toml) a typical query would be:

```http request
http://localhost:8080/api/bulk-download/s3?dataset=markets&variant=null&market=null
```
This would result in the markets.zip file being delivered to the caller assuming the file exists in the files folder.  
Otherwise an error will be reported.

The server also handles the error situations, returning a response similar to the actual serverP
- A bad request due to an error in the provided parameters
- No found error if the requested file is not located in the files folder
- Exceeding the allowed number of api calls

### How to deploy the application

1. Compile the application using the Dart SDK
2. Copy the executable to the deployment folder
3. Copy the configuration file (mock-api.toml) to the same folder and edit it if necessary
5. Start the server and point your application to it.
