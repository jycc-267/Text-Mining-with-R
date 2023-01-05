
library(tidyverse)
library(tmcn)
library(ropencc) # devtools::install_github("Lchiffon/ropencc")

zh_stopwords <- stopwords::stopwords(language = "zh", source = "misc")

# 方法一 --------------------------------------------------------------------
trad_sw <- zh_stopwords %>%
  # 整理成tibble的格式
  tibble(trad_word = .) %>% 
  # 將簡體轉成繁體
  mutate(trad_word = tmcn::toTrad(trad_word))

simp_sw <- zh_stopwords %>%
  # 整理成tibble的格式
  tibble(simp_word = .)

trad_sw %>% 
  bind_cols(simp_sw) %>% 
  mutate(same = trad_word == simp_word) %>% 
  summarize(same_rate = sum(same) / nrow(.) )

# 方法一testing ------------------------------------------------------------

toy_dat <- tibble(token = c("們", "別處"))

# 繁體字有成功移除
toy_dat %>% 
  anti_join(trad_sw, by = c("token" = "trad_word"))

# 簡體字沒有成功移除
toy_dat %>% 
  anti_join(simp_sw, by = c("token" = "simp_word"))


# 方法二 --------------------------------------------------------------------

trans_engine <- converter(S2TWP)
trad_sw_2 <- tibble(trad_word = run_convert(trans_engine, zh_stopwords))

trad_sw_2 %>% 
  bind_cols(simp_sw) %>% 
  mutate(same = trad_word == simp_word) %>% 
  summarize(same_rate = sum(same) / nrow(.) )

# 方法二testing ------------------------------------------------------------

toy_dat <- tibble(token = c("們", "別處"))

# 繁體字有成功移除
toy_dat %>% 
  anti_join(trad_sw_2, by = c("token" = "trad_word"))

trad_sw %>% 
  bind_cols(trad_sw_2) %>% 
  mutate(same = trad_word...1 == trad_word...2) %>% 
  filter(same == FALSE)
