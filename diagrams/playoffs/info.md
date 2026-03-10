## Text to generate diagram in https://www.eraser.io/diagramgpt

Playoff feature:

- An playoff is created is and open_date, when that date is reached the playoff change state to open
- When playoff is open the team can be registered and it will be opened with time_range open_timeframe
- We will allow an maximum number of teams, when reached new teams that want register will receive an message telling that max_teams was reached
- When open_timeframe is reached the playoff will change state to started and it that momen
- We will check if we have an minimum of teams if not a minimum is reached we will cancel playoff
- If everything is ok then we will start playoff, create brackets and rounds and we will send a notification using rabbitmq telling that playoff already started
- Each round will have a max allowed time to be finished and start next round, in each round timeframe we will  receive games from playoff, and register winners that will adavence for next round
- If we dont receive all the games in round timeframe we will advance the team that registers first in playoff
- Each time that we will adavance round, process games in playoff we will send an rabbitmq notification
- The process will be repeated until the last round, and after receive last game we will finish the playoff, adding the winner to playoff and send the prizes to all winners in playoff
- The playoff will change state to finished

The diagram shoud be more or less square area not only horizontal or vertical
