library(data.table)
library(dplyr)
library(tictoc)
library(janitor)

convert_to_csv <- function(filename) {
  filepath <- paste0("C:/Users/mvu02/Desktop/Projects/Movie Memo/data/IMDB/unzipped/", filename)
  csv <- as.data.frame(fread(filepath, quote = ""))
  return(csv)
}

# chunk takes ~ 2 min to run
title_basics <- convert_to_csv("title.basics.tsv")
name_basics <- convert_to_csv("name.basics.tsv")
title_crew <- convert_to_csv("title.crew.tsv")
title_episode <- convert_to_csv("title.episode.tsv")
title_principals <- convert_to_csv("title.principals.tsv")
title_ratings <- convert_to_csv("title.ratings.tsv")

fwrite(name_basics, "C:/Users/mvu02/Desktop/Projects/Movie Memo/data/IMDB/csv/name.basics.csv")
fwrite(title_crew, "C:/Users/mvu02/Desktop/Projects/Movie Memo/data/IMDB/csv/title.crew.csv")
fwrite(title_episode, "C:/Users/mvu02/Desktop/Projects/Movie Memo/data/IMDB/csv/title.episode.csv")
fwrite(title_principals, "C:/Users/mvu02/Desktop/Projects/Movie Memo/data/IMDB/csv/title.principals.csv")
fwrite(title_ratings, "C:/Users/mvu02/Desktop/Projects/Movie Memo/data/IMDB/csv/title.ratings.csv")

#title_basics <- as.data.frame(fread("C:/Users/mvu02/Desktop/Projects/Movie Memo/data/IMDB/unzipped/title.basics.tsv", quote = ""))
#fwrite(title_basics, "C:/Users/mvu02/Desktop/Projects/Movie Memo/data/IMDB/csv/title.basics.csv")

#### ERROR: CANNOT ALLOCATE VECTOR OF SIZE 400 Mb
#filenames <- c("title.basics.tsv", "name.basics.tsv", "title.crew.tsv", "title.episode.tsv", "title.principals.tsv",
#               "title.ratings.tsv")
#csv_list <- list()
#for (i in seq_along(filenames)) {
#  new_csv <- convert_to_csv(file)
#  csv_list <- append(csv_list, new_csv)
#}
#csv_list <- lapply(filenames, convert_to_csv)

# Exploratory Data Analysis 

# Movie data
head(title_basics)
unique(title_basics$titleType)

movies <- filter(title_basics, titleType == "movie")
nrow(movies)
head(movies)

# Movie star data (actor, actress, director)
head(title_principals)
unique(title_principals$category)

roles <- list("actor", "actress", "director")

principal_roles <- filter(title_principals, category %in% roles)
head(principal_roles)
unique(principal_roles$job)
principal_roles <- select(principal_roles, -job, -characters, -ordering)

head(principal_roles)
head(movies)

# Movie data & movie star data
movies_and_principals <- inner_join(movies,
                                    principal_roles,
                                    by = c("tconst"))

head(movies_and_principals)

# Movie star name data
head(name_basics)

# Movie data & movie star data & movie star name data
data <- inner_join(movies_and_principals,
                   name_basics,
                   by = c("nconst"))

head(data)


# My ratings
my_ratings <- fread("C:/Users/mvu02/Desktop/Projects/Movie Memo/data/IMDB/csv/my_ratings.csv")
head(my_ratings)
my_ratings <- filter(my_ratings, `Title Type` == "movie")

# My ratings + data
ratings_and_data <- inner_join(data,
                               my_ratings,
                               by = c("tconst" = "Const"))
head(ratings_and_data)
ratings_and_data <- ratings_and_data %>%
  select(-genres, -titleType, -`Title Type`, -runtimeMinutes, -`Title`) %>%
  clean_names()

head(ratings_and_data)
length(unique(ratings_and_data$primary_title))

######### compare titles on my_ratings and data (final join is missing 10 titles)
#not_in <- my_ratings %>%
#  filter(!Title %in% unique(ratings_and_data$primary_title) & !Title %in% unique(ratings_and_data$original_title))
#View(not_in)
#length(my_ratings$Title)
#View(filter(data, startsWith(primaryTitle, "Star Wars")))
#View(filter(movies, startsWith(primaryTitle, "Population")))

#### REASON -- found that the excluded titles had a different TitleType (tvMovie, video),
####           which is why the `data` variable did not have matching rows
####          `data` variable was filtered to only include TitleType "movie"
#### SOLUTION -- filter `my_ratings` for only rows with TitleType == "movie"