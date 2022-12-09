# advent-of-code-2022 [![Examples](../../actions/workflows/examples.yml/badge.svg)](../../actions/workflows/examples.yml) [![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[Advent of Code 2022 🎄](https://adventofcode.com/year/2022) solutions by `@Aquaj`

README is based on [Jérémie Bonal's AoC Ruby template](https://github.com/aquaj/adventofcode-template).

## What is Advent of Code?
[Advent of Code](http://adventofcode.com) is an online event created by [Eric Wastl](https://twitter.com/ericwastl).
Each year, starting on Dec 1st, an advent calendar of small programming puzzles are unlocked once a day at midnight
(EST/UTC-5). Developers of all skill sets are encouraged to solve them in any programming language they choose!

## Advent of Code Story

  Santa's reindeer typically eat regular reindeer food, but they need a lot of magical energy to deliver presents on Christmas. For that, their favorite snack is a special type of star fruit that only grows deep in the jungle. The Elves have brought you on their annual expedition to the grove where the fruit grows.

  To supply enough magical energy, the expedition needs to retrieve a minimum of fifty stars by December 25th. Although the Elves assure you that the grove has plenty of fruit, you decide to grab any fruit you see along the way, just in case.

  Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

**These were not written as example of clean or efficient code** but are simply my attempts at finding the answers to
each day's puzzle as quickly as possible. Performance logging was added simply as a fun way to compare implementations
with other competitors.

## Puzzles

<!-- On-hand emojis: ⏳ ✔ 🌟 -->
|       | Day                                                                   | Part One | Part Two | Solutions
| :---: | ---                                                                   | :---:    | :---:    | :---:
| ✔     | [Day 1: Calorie Counting](https://adventofcode.com/2022/day/1)        | 🌟       | 🌟       | [Solution](day-01.rb)
| ✔     | [Day 2: Rock Paper Scissors](https://adventofcode.com/2022/day/2)     | 🌟       | 🌟       | [Solution](day-02.rb)
| ✔     | [Day 3: Rucksack Reorganization](https://adventofcode.com/2022/day/3) | 🌟       | 🌟       | [Solution](day-03.rb)
| ✔     | [Day 4: Camp Cleanup](https://adventofcode.com/2022/day/4)            | 🌟       | 🌟       | [Solution](day-04.rb)
| ✔     | [Day 5: Supply Stacks](https://adventofcode.com/2022/day/5)           | 🌟       | 🌟       | [Solution](day-05.rb)
| ✔     | [Day 6: Tuning Trouble](https://adventofcode.com/2022/day/6)          | 🌟       | 🌟       | [Solution](day-06.rb)
| ✔     | [Day 7: No Space Left On Device](https://adventofcode.com/2022/day/7) | 🌟       | 🌟       | [Solution](day-07.rb)
| ✔     | [Day 8: Treetop Tree House](https://adventofcode.com/2022/day/8)      | 🌟       | 🌟       | [Solution](day-08.rb)
| ✔     | [Day 9: Rope Bridge](https://adventofcode.com/2022/day/9)             | 🌟       | 🌟       | [Solution](day-09.rb)
|       | [Day 10: TBD](https://adventofcode.com/2022/day/10)                   |          |          | [Solution](day-10.rb)
|       | [Day 11: TBD](https://adventofcode.com/2022/day/11)                   |          |          | [Solution](day-11.rb)
|       | [Day 12: TBD](https://adventofcode.com/2022/day/12)                   |          |          | [Solution](day-12.rb)
|       | [Day 13: TBD](https://adventofcode.com/2022/day/13)                   |          |          | [Solution](day-13.rb)
|       | [Day 14: TBD](https://adventofcode.com/2022/day/14)                   |          |          | [Solution](day-14.rb)
|       | [Day 15: TBD](https://adventofcode.com/2022/day/15)                   |          |          | [Solution](day-15.rb)
|       | [Day 16: TBD](https://adventofcode.com/2022/day/16)                   |          |          | [Solution](day-16.rb)
|       | [Day 17: TBD](https://adventofcode.com/2022/day/17)                   |          |          | [Solution](day-17.rb)
|       | [Day 18: TBD](https://adventofcode.com/2022/day/18)                   |          |          | [Solution](day-18.rb)
|       | [Day 19: TBD](https://adventofcode.com/2022/day/19)                   |          |          | [Solution](day-19.rb)
|       | [Day 20: TBD](https://adventofcode.com/2022/day/20)                   |          |          | [Solution](day-20.rb)
|       | [Day 21: TBD](https://adventofcode.com/2022/day/21)                   |          |          | [Solution](day-21.rb)
|       | [Day 22: TBD](https://adventofcode.com/2022/day/22)                   |          |          | [Solution](day-22.rb)
|       | [Day 23: TBD](https://adventofcode.com/2022/day/23)                   |          |          | [Solution](day-23.rb)
|       | [Day 24: TBD](https://adventofcode.com/2022/day/24)                   |          |          | [Solution](day-24.rb)
|       | [Day 25: TBD](https://adventofcode.com/2022/day/25)                   |          |          | [Solution](day-25.rb)

## Running the code

Run `bundle install` to install any dependencies.

Each day computes and displays the answers to both of the day questions and their computing time in ms. To run it type `ruby day<number>.rb`.

If the session cookie value is provided through the SESSION env variable (dotenv is available to provide it) — it will
fetch the input from the website and store it as a file under the `inputs/` folder on its first run.
Lack of a SESSION value will cause the code to raise an exception unless the input file (`inputs/{number}`) already
present. The code will also raise if the input isn't available from AoC's website (`404` error).
