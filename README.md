# Mock-API

![Splash](docs/splash.png)

## Introduction

This is an example of how to use the [Dart language](https://dart.dev/) to quickly build a API mock server to aim
your application at during development and testing.

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

This mock server performs a very simple function.  It serves zip files from a folder (files) located next to the deployed
executable based on the combination of parameters send with the query to the server and documented above.  For example the
following query:

```http request
http://localhost:8080/api/bulk-download/s3?dataset=markets&variant=null&market=null
```
will result in the markets.zip file being delivered to the caller assuming the file exists in the files folder.  Otherwise
an error will be reported.

The server can be further configured via it's configuration file (mock-api.toml):

- Change the port used by the server
- Validate the api key
- Throw one of a number of defined errors using the defined in the config file
- limit the number of requests that can be made to the server

### How to deploy the application

1. Compile the application using the Dart SDK
2. Copy the executable to the deployment folder
3. Copy the configuration file (mock-api.toml) to the same folder and edit it if necessary
4. Create a sub folder within the deployment folder and copy the collection of zip files to it
5. Start the server and point your application to it.
