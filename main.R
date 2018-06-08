library(tidyverse)
library(plotly)

source("colors.R")

df <- read_csv('libs.csv') %>%
  filter(date > '2017-05-22')

first_date = first(df$date)
last_date = last(df$date)

deltas <- df %>%
  group_by(library, client) %>%
  summarize(first_value=min(frequency),
           last_value=max(frequency), 
           total_frequency=sum(frequency)) %>%
  mutate(delta = last_value-first_value,
         delta_percent = 100 * (last_value - first_value) / first_value)

top_n = deltas %>% arrange(desc(total_frequency)) %>% head(n=20)

# We care about libraries with highly variable popularity, which exceed a minimum popularity bar.
# Or just libraries which are generally of interest.
interesting_sites <- inner_join(df, deltas) %>%
  filter((abs(delta_percent) > 40 & total_frequency > 3500) |
         library %in% c("Polymer", "Google Maps", "React", "jQuery"))

#order <- interesting_sites %>% filter(client == "desktop") %>% group_by(library) %>% summarize(v=last(frequency)) %>% arrange(desc(v))
order <- interesting_sites %>% group_by(library) %>% summarize(v=last(frequency)) %>% arrange(desc(v))

interesting_sites$library <- factor(interesting_sites$library, order$library)

interesting_sites %<>% 
  mutate(text = sprintf("Date: %s<br>Library: %s<br>Page Count: %f", format(date, "%Y/%m/%d"), library, frequency))

plot <- ggplot(interesting_sites, aes(x=date, y = frequency, color=library, text=text, group=1)) +
#plot <- ggplot(interesting_sites, aes(x=date, y = frequency, color=library)) + 
  geom_line(size=2) +
  scale_color_manual(values=colors) +
  scale_y_log10() +
  facet_wrap(~client, ncol=1) +
  ylab("Page count") +
  ggtitle("Library Usage")

#ggsave("libraries_over_time.png", plot=plot, width=8, height=10, dpi=200)
