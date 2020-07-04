Using learnr to collect data
================

## Rough Draft

#### Using learnr to collect data

``` r
library(rdrop2)

# outside the shiny app
token <- drop_auth()
saveRDS(token, "droptoken.rds")

# inside the shiny app
drop_auth(rdstoken = "droptoken.rds")
```

``` r
event_recorder <- function(tutorial_id, tutorial_version, user_id, event, data) {
  
  # code goes here
  
}

options(tutorial.event_recorder = event_recorder)
```

``` r
  ... {

if (drop_exists(glue("teaching-r-study/data_{user_id}.rds"))) { 
  
  drop_download(path = glue("teaching-r-study/data_{user_id}.rds"),
                local_path = glue("data_{user_id}.rds"),
                overwrite = TRUE) }
  
  t <- readRDS(glue("data_{user_id}.rds"))
  
else {# code goes here} 
  
  ...
 
}
```

### data frame, t

<img src="images/figure4.png" width="25%" />

``` r
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
```

``` r
{
  
  if (drop_exists(glue("teaching-r-study/data_{user_id}.rds"))) {
    
    ...
    
    }
  
  else{
    
    ...
    
    }
  
  # code goes here
  
}
```

``` r
{ 
  
  ...
  
  t <- bind_rows(t, tibble(
    time = Sys.time(),
    tutorial_id = tutorial_id,
    tutorial_version = tutorial_version,
    user_id = user_id,
    event = event,
    data = list(data))
    )
  
  # code goes here


}
```

<img src="images/figure5.png" width="40%" />

``` r
{
  ...
  
  saveRDS(t, file = glue("data_{user_id}.rds"))
  drop_upload(file = glue("data_{user_id}.rds"),
              path = "teaching-r-study")

}
```

-----

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

## What we have so far

### sneak peak at what the current pilot looks like

<img src="images/figure6.png" width="65%" />

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

<div id="refs" class="references hanging-indent">

<div id="ref-Lucymcgowan/Talks">

McGowan, Lucy D’Agostino. 2020. “Best Practices for Teaching R a
Randomized Controlled Trial.” Presentation. *Lucymcgowan.com/Talks*.
[ocs.google.com/presentation/d/1kOtqXMWhNE6OjInt32PnkBC\_j\_GfVQ-rJKzFxOn29yM/edit?usp=sharing](ocs.google.com/presentation/d/1kOtqXMWhNE6OjInt32PnkBC_j_GfVQ-rJKzFxOn29yM/edit?usp=sharing).

</div>

</div>
