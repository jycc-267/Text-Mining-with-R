# 這是Shiny App 的「使用者界面」（user interface）。
# 要執行的話，請點選右上角的"Run App"。
# 其他參考資訊：http://shiny.rstudio.com/

library(shiny)

# 設計使用者界面
shinyUI(fluidPage( # 依使用者的瀏覽器介面調整視覺化比例

    # Application title
    titlePanel("Make Your Textual Data 'Shiny'!"),

    # 可以選擇很多layout，這裡使用SidebarLayout樣板：其中包含sidebarPanel與mainPanel
    sidebarLayout(
        
        # 這邊都還是sidebarPanel可以選擇的項目
        sidebarPanel(
            
            # 以滑桿調整參數
            # 選擇ngram
            # inputId = "ngram"的意思就像是在ui端定義叫input的list，放入一個叫做ngram的物件: input$ngram
            sliderInput(inputId = "ngram", # inputId會對應到server的object名稱，告訴server該如何處理資料
                        label = "Tokenization: N-gram:", # 使用者看到的參數label名稱
                        min = 1, # 參數的範圍
                        max = 7,
                        value = 1), # 預設值
            
            # 選擇展示多少筆資料
            numericInput(inputId = "display_n",
                         label = "How many tokens do you want to display:", 
                         min = 20,
                         max = Inf,
                         value = 25)
        ),
    
        # 主畫面要展示的資料成果
        mainPanel(
            # 畫圖展示
            plotOutput(outputId = "freqPlot"), #將server端做好的圖用outputId對應過來
            # 製表展示，DT套件的呈現比較好看
            DT::dataTableOutput(outputId = "token_tab")
        )
    )
))

