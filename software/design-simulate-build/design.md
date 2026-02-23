
# Core Ideas

1. Gather functional requirements.
    - These are the business's needs slash product goals.
    - What should the product or tool do?
    - How does that contribute to a successful business outcome?
    - Exit point: do we have the capabilities as an organization to execute on these requirements? If no abandon the project now!

2. Define core types.
    - What data am I working with?
    - What do I expect to receive?
    - What do I expect to send?
    - What are my inputs and outputs?
    - Are there any supplemental types I need to achieve the business objective?
    - Define them!
        - Loosely but think about what you need.
        - id is an integer.
        - name is a string.
        - location is a tuple of lat, long.

3. Gather non-functional requirements.
    - Conjecture about latency requirements.
        - Hard real-time, consumed with significant delay, or somewhere in between?
    - Conjecture about message volume and size.
    - Consider GDPR and data-residency requirements.
        - What architectural trade-offs will you need to make to accommodate these legal frameworks.
    - Consider CAP theorem. What trade-off do you want to make.
    - Exit point: do we have the capabilities as an organization to execute on these requirements? If no abandon the project now!
    - Exit point: is there anything about these requirements which pushes the project into impossibility? Abandon the project or loosen constraints!

4. High level architecture design.
    - You know what the product's requirements are. You know what the core data types are. Now define an architecture that can accommodate.
    - Pick the intersection of technologies that solve your problem and are readily available within your organization.
        - New technologies can be brought on but they are a burden on the organization.
        - Requires training, continuous maintenance routines, and introduces new points of failure.
        - But can be worth it if the business can justify it.
    - Edge case for start-ups: if a new business pick technologies which have a reputation for easy maintenance and high reliability.
        - Regardless of technical trade-offs.
        - That means you might be using embedded SQLite when at scale you would want Kafka.
        - That's okay! When you need the scale you'll have the money to pay people to take on the maintenance burden.

5. Define your interfaces (wire serialization format).
    - When communicating over the wire we need a well-known communication format.
    - Describe what API blueprints are.
    - Provide a simple example blueprint.
    - Cite any evidence that supports using API blueprints as a communication mechanism.
        - It should demonstrate how utilizing API blueprints lead to better outcomes.
    - Describe how an API blueprint enables engineers from different disciplines to work in parallel.
    - Design by contract.
    - Use a well-known API specification.
        - JSONAPI for RESTful JSON APIs.
    - Exit point: reflect! Do these interfaces solve the product requirements? What trade-offs did we have to make to get here? Is this project still worth pursuing?

6. Define your tickets.
    - Assign tickets to relevant parties.
    - In an n-tier architecture.
        - A front-end UI ticket.
        - A back-end API ticket.
        - Any other tickets you need for your other services.
    - You can have any number of people working on the project.
        - Just ensure the scope each person is working on is isolated.
        - We don't want parallel work happening which occurs communication overhead (contention).
        - Beware of shared dependencies. Put more work on a single engineer rather than deal with communication gridlock.
    - Communication is inevitable.
        - You will learn things during the work.
        - Revise your plans from the previous sections as you learn more.
    - Meaningful progress will be made to bring the project to reality.
        - Even though we're in the design phase these are real tickets.
        - Design is iterative and must evolve to survive its contact with reality.
    - Design work can happen in parallel in code (see section 7).

7. Define your interfaces (in process).
    - When communicating with other modules we want to expose simple, declarative interfaces.
    - Design by contract.
    - Functions should accept higher-order functions which satisfy the function's constraints.
    - The logic of the function can be implemented in its entirety without ever interacting with the outside world.
        - The world is effectively mocked by our higher-order functions.
        - This means we can design in code the way we would design in a notion doc.
        - Because your programming language is formal and is purpose-built for the problem of programming this can challenge your assumptions and give you early signal to change your design.
        - A significant fraction of your project's code requirements (nearly 100%) can be satisfied in the design phase.
            - Its only at the end when you build the project that the outside world becomes relevant.
    - You may think writing code in the design phase seems counter-intuitive.
        - Aren't we trying to avoid code by designing?
        - But no. Code isn't actually the artifact we want to avoid.
        - Your impact on the world is the significant challenge.
            - The servers you spin up.
            - The third-party services you integrate against.
            - The customers you contact.
            - The database migrations you perform.
            - The runbooks you create.
        - Migrations and maintenance are the ongoing concerns which will consume >100x the time it took you to formalize your logic in your programming language.
    - How much of my use case should I define in code?
        - Everything!
        - Logic, IO, metrics, logs, billing.
        - Use higher order functions. Don't define concrete implementations.
        - But the intention to log, the intention to bill, the intention to emit a metric should be there.

# Conclusion

- These steps are optional.
- You can skip or half-ass any step you want.
- But do so at your own risk.
- Whatever time you save now will be spent later.
- And the time you save now will likely be spent now when the complexity vampire drains your time.
- Design brings certainty to software.
- Certainty gives you a firm foundation and allows you to fearlessly build on past work.
- You can not stand when the ground beneath you crumbles.

# Software Design Before You Build

Software design is the process of defining a system's structure, interfaces, and behavior before writing production code. Frederick Brooks, in *The Mythical Man-Month* (1975), observed that conceptual integrity — a consistent, coherent design — is the most important factor in system quality. More recently, research published in *IEEE Software* has found that defects introduced during the design phase cost significantly more to fix once a system is in production than defects caught during design review.

This post describes a repeatable process for designing backend web services and distributed systems.

---

## 1. Gather Functional Requirements

Functional requirements describe what a system must do. They are derived from business or product goals.

Questions to answer at this stage:

- What should the system do?
- What business outcome does each requirement serve?
- Does the organization have the capability to execute on these requirements?

The last question is an exit point. If the answer is no, stop. Proceeding without the capability to deliver a requirement produces waste — time spent on a system that cannot be shipped or maintained.

---

## 2. Define Core Types

Before choosing an architecture, define the data the system will work with. Loose definitions are sufficient at this stage.

Questions to answer:

- What data does the system receive?
- What data does the system produce?
- What supplemental types are needed to satisfy the requirements?

A simple example:

```
id: integer
name: string
location: (latitude: float, longitude: float)
```

Defining types early surfaces ambiguities in requirements. If a type cannot be defined, the requirement it supports may not be well-understood.

---

## 3. Gather Non-Functional Requirements

Non-functional requirements constrain how the system must behave, independent of specific features. They include:

**Consistency and availability trade-offs.** The CAP theorem states that a distributed system can guarantee at most two of the following three properties: consistency, availability, and partition tolerance. Understanding which properties the business requires informs architecture choices.

**Latency.** Does the system require hard real-time response (milliseconds), near-real-time, or is significant delay acceptable? The answer affects technology selection.

**Message volume and size.** Estimating throughput and payload size determines whether a given technology can handle the load.

**Data residency and compliance.** Regulations such as GDPR impose constraints on where data is stored and processed. These constraints have architectural implications that should be identified before design decisions are made.

This stage has two exit points:

1. If the organization lacks the capability to meet the non-functional requirements, stop.
2. If the non-functional requirements make the project technically infeasible, either stop or revise the requirements.

---

## 4. High-Level Architecture Design

With functional and non-functional requirements defined, and core types understood, the next step is selecting an architecture.

The practical guidance here is to pick the intersection of technologies that solve the problem and are already available within the organization. Introducing a new technology carries ongoing costs: training, maintenance, and a new failure surface.

**A note for early-stage organizations.** When a business is new and revenue is limited, the highest priority is reliability and maintainability, not scale. A simpler technology (for example, SQLite instead of a distributed message queue) is often the correct choice. When scale becomes a constraint, the organization will have the resources to address it.

---

## 5. Define Wire Interfaces

Services that communicate over a network require a well-defined serialization format and API contract.

An API blueprint is a document that specifies the endpoints, request formats, response formats, and error conditions of a service before that service is built. API blueprints enable engineers working on different parts of a system to work in parallel, because each party knows exactly what to expect from the other.

This practice is sometimes called **design by contract**: each component commits to a specific interface, and other components depend on that contract rather than on an implementation.

Using a well-known specification format reduces ambiguity. For RESTful JSON APIs, [JSON:API](https://jsonapi.org) is one such specification.

**Exit point.** After defining wire interfaces, reflect: do these interfaces satisfy the product requirements? What trade-offs were made? Is the project still worth pursuing?

---

## 6. Define Work Tickets

With interfaces defined, work can be decomposed into tickets and assigned to individuals.

In a layered architecture, this typically means:

- A ticket for the front-end UI
- A ticket for the back-end API
- Tickets for any additional services

The key constraint is that each ticket should represent a scope of work that is isolated from other concurrent work. Parallel work that shares a dependency creates coordination overhead and slows delivery more than having a single engineer handle the dependency alone.

Communication is unavoidable during execution. What is learned while building should feed back into the design. Plans made in the previous sections should be revised as new information emerges.

---

## 7. Define In-Process Interfaces

Within a service, modules communicate through function calls and shared abstractions. The same principle of design by contract applies here.

A useful technique is to write functions that accept their dependencies as parameters — a form of dependency injection. A function that needs to read from a database accepts a function that reads from a database, rather than calling the database directly. This means:

- The logic of the function can be written and reasoned about without an actual database.
- The function can be exercised with test inputs that simulate any behavior.
- The design expressed in code is a formal specification, and the programming language will surface logical inconsistencies that prose documents would not.

This approach allows most of a system's logic to be specified during the design phase. The remaining work — connecting the system to real infrastructure, running migrations, integrating third-party services — is a smaller and better-understood task once the logic is defined.

The artifacts to avoid are not lines of code. They are production side-effects: server provisioning, database migrations, customer-facing changes, runbooks. These carry ongoing maintenance costs that can exceed the original development effort by a large factor. Code that expresses intent, absent those side-effects, is low-cost to write and revise.

At this stage, define everything: logic, IO, metrics, logging, billing. Use abstractions. Do not wire up concrete implementations until you are ready to build.

---

## Conclusion

Each step in this process is optional. Any step can be skipped. The consequence is that complexity deferred to later stages costs more to resolve than complexity addressed during design. Time saved by skipping design is generally spent later, often at a higher rate, when the cost of changing a deployed system is higher than the cost of changing a document or a draft interface.

A design process produces certainty. Certainty allows work to proceed without revisiting settled questions. Systems built on a clear design are easier to extend, easier to debug, and easier to hand off.
