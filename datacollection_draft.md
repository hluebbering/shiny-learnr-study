Collecting data using learnr
================

## Rough Draft

### shiny + learnr + rdrop2 for data collection

-----

By collecting data on each user interaction through a shiny application,
we can assess countless evidence of a module’s success in teaching basic
data manipulation tasks. For this study, the R tutorial collects three
types of datasets: demographic, assessment, and exercise data.

The **demographic data** collects information on the user’s description,
such as data science experience, studies, interests, age, gender, etc.

The **assessment data** pulls in each user attempt of a given data
manipulation task.

The **exercise data** gathers user performance on the learnr module’s
interactive tasks assigned a console where students can try to type it
out themselves.

All of this data combined permits a way to assess student comprehension
and understanding of a given modality.

-----

The three main tools that permit automatic and continuous data
collection are the **shiny, rdrop2, and learnr packages** in R. First,
install the rdrop2 package, which provides the dropbox package. Dropbox
continuously collects and stores user data. We start the learner module
from the main code of rdrop2, which contains the link between R and
`dropbox`.

Outside of the shiny app, we create a token for the authentications and
save it as an RDS file. This process makes sure the app can communicate
with the dropbox. In the app itself, we then reference the token (saved
as an RDS file), and the authentications to get the app in cahoots with
the dropbox. Once authenticated, we can tie into learnr to pull data
from each student’s interaction: clicks, completions, skips, attempts,
results, etc.

``` r
library(rdrop2)

# outside the shiny app
token <- drop_auth()
saveRDS(token, "droptoken.rds")

# inside the shiny app
drop_auth(rdstoken = "droptoken.rds")
```

-----

At this point, we start a new r code block, which has the function of
recording every interaction of student records in R. The function has
five inputs: the tutorial id, tutorial version, user id, event, and
data. For any given user, the user id, events, and data will be unique.
Hence, each user classifies under a unique identifier, completes
exclusive events (completing an exercise, skipping a section, answering
a demographic survey, etc.), and links to an individual data that lists
each event results.

``` r
event_recorder <- function(tutorial_id, 
                           tutorial_version,
                           user_id,
                           event, 
                           data)
  {
  
  ...
  
  }

options(tutorial.event_recorder = event_recorder)
```

User ID is an essential mechanism for tracking individual progress in
the learner module. Hence, a student can leave the tutorial and return
where they left off since all development automatically stores in their
id. At the end of the r code block, the learner module sets the tutorial
event recorder to the recorder created for the study.

-----

Now, we fill in the essential part of the function.

``` r
event_recorder <- function(tutorial_id, tutorial_version, user_id, event, data) {
  
  if (drop_exists(glue("teaching-r-study/data_{user_id}.rds"))) {
    
    ...
    
    }
  
  else{
    
    ...
    
  }
  
  ...
  
  
  }
```

-----

The first piece defines the ‘if’ statement; this is where the function
searches dropbox for existing user data.

``` r
  ... {
    
    if (drop_exists(glue("teaching-r-study/data_{user_id}.rds"))) {
      
      # code goes here
      
    }
    
    # code goes here
    
    ...
    
    }
```

Throughout the task, we use the glue package to tie together strings.
The glue package instructs this piece of code, in a single command, to
search the indicated dropbox folder for prior data under the user’s
unique id. If there’s data, then the function proceeds to download that
data to the indicated path; and override it to the indicated path.

``` r
  ... {
    
    if (drop_exists(glue("teaching-r-study/data_{user_id}.rds"))) {
      
      drop_download(path = glue("teaching-r-study/data_{user_id}.rds"),
                    
                    local_path = glue("data_{user_id}.rds"),
                    
                    overwrite = TRUE) }
    
    # code goes here
```

Lastly, the rds file reads into a local data frame called t. We use the
glue package to link the data to the user id, hence, ensuring the
dataset remains unique for each student.

``` r
... {
    if (drop_exists(glue("teaching-r-study/data_{user_id}.rds"))) {
      drop_download(path = glue("teaching-r-study/data_{user_id}.rds"),
                    local_path = glue("data_{user_id}.rds"),
                    overwrite = TRUE) }
    
    t <- readRDS(glue("data_{user_id}.rds"))
    
    ...
    
  }
```

**data frame, t**

<img src="images/figure4.png" width="25%" />

-----

Next, we define the else statement, which provides alternative commands
when data doesn’t exist in the dropbox. When there’s no data to
download, the function creates an empty data frame called t. The data
set is unique to the user, and it accepts six inputs: current time,
tutorial id, tutorial version, user id, event, and data.

``` r
... {
  ...
  
  else {
    t <- tibble(
      time = .POSIXct(numeric(0)),
      tutorial_id = character(),
      tutorial_version = character(),
      user_id = character(),
      event = character(),
      data = list())
  }
  
  ...
}
```

<img src="images/figure4.png" width="25%" />

-----

Consequently, defining the if-else part pulls in the data frame t that
either includes a former user’s old data frame or creates a new user’s
empty data frame. We define a mechanism to bind the rows of the data
frame, which takes the original data frame and adds an extra row.

``` r
... {
  if (drop_exists(glue("teaching-r-study/data_{user_id}.rds"))) {
    drop_download(path = glue("teaching-r-study/data_{user_id}.rds"),
                  local_path = glue("data_{user_id}.rds"),
                  overwrite = TRUE) }
  t <- readRDS(glue("data_{user_id}.rds"))
  
  else {t <- tibble(
    time = .POSIXct(numeric(0)),
    tutorial_id = character(),
    tutorial_version = character(),
    user_id = character(),
    event = character(),
    data = list())}
  
  t <- bind_rows(t, tibble(
    time = Sys.time(),
    tutorial_id = tutorial_id,
    tutorial_version = tutorial_version,
    user_id = user_id,
    event = event,
    data = list(data))
    )
  
}
```

<img src="images/figure5.png" width="40%" />

Lastly, we instruct the code to save the RDS so that, whenever a user
interacts with the tutorial, the function automatically appends a new
row to the user’s data frame. This process documents constant updates to
the data frame and uploads it back onto dropbox.

``` r
... {
  ...
  
  saveRDS(t, file = glue("data_{user_id}.rds"))
  drop_upload(file = glue("data_{user_id}.rds"),
              path = "teaching-r-study")
  }
```

-----

#### Putting it all together

``` r
event_recorder <- function(tutorial_id, tutorial_version, user_id, event, data) {
  
  if (drop_exists(glue("teaching-r-study/data_{user_id}.rds"))) {
    drop_download(path = glue("teaching-r-study/data_{user_id}.rds"),
                  local_path = glue("data_{user_id}.rds"),
                  overwrite = TRUE) }
  
  t <- readRDS(glue("data_{user_id}.rds"))
  
  else {t <- tibble(
    time = .POSIXct(numeric(0)),
    tutorial_id = character(),
    tutorial_version = character(),
    user_id = character(),
    event = character(),
    data = list())}
  
  t <- bind_rows(t, tibble(
    time = Sys.time(),
    tutorial_id = tutorial_id,
    tutorial_version = tutorial_version,
    user_id = user_id,
    event = event,
    data = list(data)))
  
  saveRDS(t, file = glue("data_{user_id}.rds"))
  drop_upload(file = glue("data_{user_id}.rds"),
              path = "teaching-r-study")
}
```

-----

Now, we look into the deployment of questions. By default, the learnr
module writes questions with correct answers and provides instant
feedback that unveils the solution. However, this study uses assessments
that aren’t supposed to give away solutions immediately. To change the
module’s default, we create a new class of a keyword in the r space that
marks every answer as correct, so the user can’t see the right answer.
Since the module requires some solution that’s correct, we set the
question type to always correct. Regardless of whether answered
correctly, the user will get the right answer, letting them know they
completed their submission and can move on.

``` r
question_is_correct.always_correct <- function(question, value, ...) {
  return(mark_as(TRUE, message = NULL))
}
```

``` r
question("This is your question?",
         answer("This is an answer..", correct = TRUE),
         type = c("always_correct", "radio_button"),
         correct = "Submitted")
```

-----

Now, we have a sneak peek at what the data will look like when going
through the tutorial. There’s a column for each of the function inputs:
current time, tutorial id, tutorial version, user id, event, and data.

The data, a different list for each user event, holds the most critical
information for analyzing results. We can organize and sift through the
copious amounts of data by using the tidycode and Matahari packages;
these packages provide a way to capture and analyze the code in the
tutorial.

<img src="images/figure6.png" width="65%" />

First, check the data’s labels, which path a particular event where the
information recording occurs. To ease the organization, we can change
indiscernible filenames to be more legible. Next, check the data’s code
to see exactly what the user inputs into an event. Then, check the
data’s output that reveals what the user sees in the tutorial. Now,
check the data’s error messages to look at all reports of user mistakes.
Next, check the data’s marks to verify the completion of tasks. Lastly,
check the data’s feedback to view what the user observes for completing
a given event.

``` bash
> data_lucymcgowan$data[[1]]

$label
[1] "vector"

$code
[1] "\n\nc(2,4,6,8)\n"

$output
<pre><code>[1] 2 4 6 8</code></pre>
<div class="alert alert-success" role="alert">Superb work! </div>
  
$error_message 
NULL

$checked
[1] TRUE

$feedback
```

As for questions checking for accuracy, the data’s feedback also
displays whether a user got the event right. This data snapshot collects
in the background of the shiny app, and then automatically sends any
update or change to dropbox.

``` bash
> data_lucymcgowan$data[[1]]$feedback

$feedback$message
Superb work!
  
$feedback$correct
[1] TRUE

$feedback$type [1] 
"success"

$feedback$location [1] 
"append"
```

-----

In conclusion, this study emphasizes the simplicity of using R Shiny,
rdrop2, and learner packages to deploy a discrete method for collecting
user participation data. By providing access to all user attempts,
operations, clicks, skips, errors, time, etc. in a tutorial, R furthers
valuable data collection, leading to vital analysis for answering
complex questions.

<div id="refs" class="references hanging-indent">

<div id="ref-Lucymcgowan/Talks">

McGowan, Lucy D’Agostino. 2020. “Best Practices for Teaching R a
Randomized Controlled Trial.” Presentation. *Lucymcgowan.com/Talks*.
[ocs.google.com/presentation/d/1kOtqXMWhNE6OjInt32PnkBC\_j\_GfVQ-rJKzFxOn29yM/edit?usp=sharing](ocs.google.com/presentation/d/1kOtqXMWhNE6OjInt32PnkBC_j_GfVQ-rJKzFxOn29yM/edit?usp=sharing).

</div>

</div>
