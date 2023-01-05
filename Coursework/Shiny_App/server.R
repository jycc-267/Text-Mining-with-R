# 這是Shiny App 的「伺服器界面」（server）。
# 要執行的話，請點選右上角的"Run App"。

library(shiny)
library(tidyverse)
library(tidytext)
library(DT) # install.packages("DT")

# data
trump <- readr::read_csv("trump_twitter_archive.csv") %>% 
    mutate(text = str_squish(text)) %>% 
    select(text)

stop_words_add <- tidytext::stop_words %>% 
    bind_rows(tibble(word = c("amp", "t.co", "https", "trump"), 
                     lexicon = rep(NA, 4)))

# 這裡開始才是shiny的code
# 決定你的server要怎麼處理資料
# 在server端產生output的list，之後在ui會從list取出來使用
shinyServer(function(input, output) {
    
    # 把產生的表，存在output$token_tab，留待ui的mainPanel使用
    output$token_tab <- DT::renderDataTable({ #An expression that returns a data frame or a matrix.
        trump_clean <- trump %>% 
            tidytext::unnest_tokens(input = "text", 
                                    output = "token", 
                                    # 這裡的token = "ngram"是argument的設定，與input的資料無關。
                                    token = "ngrams", 
                                    # 這裡塞入在ui端事先定義好的 n = input$ngram，就變成是可以透過使用者選擇而調整。
                                    n = input$ngram) %>% 
            # 如果是bigram以上，用現在的方式移除停用詞就沒有效果
            anti_join(stop_words_add, by = c("token" = "word")) %>% 
            count(token, sort = TRUE) %>% 
            # 這邊同樣是使用者可以選擇要呈現多少資料。
            top_n(input$display_n, wt = n)
    })
    
    # 把產生的圖，存在output$freqPlot，留待ui的mainPanel使用
    output$freqPlot <- renderPlot({ # An expression that generates a plot.
        # 因為每個outputId資料都是獨立的，所以剛剛的資料如果要拿來用，要重複做一次。
        trump_clean <- trump %>% 
            tidytext::unnest_tokens(input = "text", 
                                    output = "token", 
                                    token = "ngrams", 
                                    n = input$ngram) %>% 
            # 如果是bigram以上，用現在的方式移除停用詞就沒有效果
            anti_join(stop_words_add, by = c("token" = "word")) %>% 
            count(token, sort = TRUE) %>% 
            top_n(input$display_n, n)
        
        # 依照前面的資料把圖畫出來
        ggplot(trump_clean, aes(x = reorder(token, n), y = n)) +
            geom_col(show.legend = FALSE) + 
            coord_flip() + 
            theme_bw() +
            labs(x = "", y = "count")
        
    })
})
