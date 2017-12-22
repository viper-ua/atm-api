# RESTful API built with Grape for ATM test project

## Environment:
- Grape 1.0.1
- Rails 5.1.4
- Ruby 2.4.2p198

## To run this app in development mode:
- clone repository to desired place
```bash
git clone https://github.com/viper-ua/atm-api.git
```
- go inside project directory and install necessary dependencies
```bash
cd atm-api
bundle install
```
- run API server
```bash
rails s
```
>Server should start at tcp://0.0.0.0:3000

## API endpoints:
- check current ATM load
```
GET /check
```
- load ATM
```
POST /load {"stack":{"1":..., "2":...}}
```
Supported note keys are: 1, 2, 5, 10, 25, 50. If note is not loaded, it can be omitted, i.e. "5"
```
POST /load {"stack":{"1":2, "2":5, "10":7, "25":3, "50":1}}
```
- withdraw some money
```
POST /withdraw amount=xxx
```
If withdrawal is not possible, response will contain closest possible proposal for lower amount
