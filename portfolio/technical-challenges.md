# Technical Challenges — Cartify

## Keyless catalogue

A local in-code catalogue avoids product APIs, API keys and network failures while still supporting realistic filtering and search.

## Pricing correctness

Discounts and totals are computed in a pure view model rather than view controllers, enabling direct unit tests for edge cases such as empty carts and invalid promo codes.

## Cart persistence

`Codable` cart items are stored in `UserDefaults`, providing durable state without Core Data or a backend.

## Programmatic UIKit

Collection views, stack views and constraints are built in code, including adaptive grids and cart cells with stepper controls.

## Physical-device testing

No hardware-specific behaviour is required; checkout is explicitly simulated.
