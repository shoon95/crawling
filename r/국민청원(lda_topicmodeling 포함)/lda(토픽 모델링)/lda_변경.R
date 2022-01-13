install.packages('BiocManager')
pacman::p_load('rvest','dplyr','openxlsx','stringr','stringi','httr','jsonlite','tidyverse','KoNLP','tm','BiocManager','slam','topicmodels','lda','tidytext', 'ggplot2','tidyr','textmineR','ldatuning','LDAvis','Rmpfr')

setwd('D:\\R_Å©·Ñ¸µ\\Å©¸ù_±¹¹ÎÃ»¿ø')

data = read.xlsx('Å©¸ù_±¹¹ÎÃ»¿ø.xlsx')

text_data = data[,6]

useNIADic() 


cps<- VCorpus(VectorSource(text_data))

myRemove = content_transformer(function(x, pattern){return(gsub(pattern, "",x))})
toSpace = content_transformer(function(x, pattern){return(gsub(pattern," ",x))})

cps = tm_map(cps, content_transformer(tolower))
cps = tm_map(cps, myRemove, "\n|\t")
cps = tm_map(cps, myRemove, "f|ht)tp\\S+\\s*")
cps = tm_map(cps, myRemove, "https")
cps = tm_map(cps, myRemove, "http")
cps = tm_map(cps, myRemove, "www\\.+\\S+")
cps = tm_map(cps, myRemove, "o")
cps = tm_map(cps, myRemove, "¾ú½À´Ï´Ù")
cps = tm_map(cps, myRemove, "±×µ¿¾È")
cps = tm_map(cps, myRemove, "¤Ñ")
cps = tm_map(cps, myRemove, "the")
cps = tm_map(cps, myRemove, '¾È³çÇÏ¼¼¿ä')
cps = tm_map(cps, myRemove, '¾È³çÇÏ½Ê´Ï±î')
cps = tm_map(cps, myRemove, '¾È³ç')
cps = tm_map(cps, myRemove, 'º» °Ô½Ã¹°ÀÇ ÀÏºÎ ³»¿ëÀÌ ±¹¹Î Ã»¿ø ¿ä°Ç¿¡ À§¹èµÇ¾î °ü¸®ÀÚ¿¡ ÀÇÇØ ¼öÁ¤µÇ¾ú½À´Ï´Ù')
cps = tm_map(cps, myRemove, 'ÀÌ·¯ÇÏ')
cps = tm_map(cps, myRemove, 'Ã»¿ø')
cps = tm_map(cps, myRemove, '¾î¶°ÇÏ')
cps = tm_map(cps, myRemove, 'µé')
cps = tm_map(cps, myRemove, 'ÀÖ½À´Ï´ÙÇÏÁö¸¸')
cps = tm_map(cps, myRemove, 'ÇÑ¸¶µð')
cps = tm_map(cps, myRemove, '¸¶Áö¸·')
cps = tm_map(cps, myRemove, '´ÙÀ½³¯')
cps = tm_map(cps, removePunctuation)
cps = tm_map(cps, removeNumbers)
cps = tm_map(cps, toSpace, ":")
cps = tm_map(cps, toSpace, ";")
cps = tm_map(cps, toSpace, "/")
cps = tm_map(cps, toSpace, "//.")
cps = tm_map(cps, toSpace, "////")


## ¸í»ç ÃßÃâ±â

ko.words <- function(doc){
  d <- as.character(doc)
  extractNoun(d)
}

# 
# # ¸í»ç/ Çü¿ë»ç/ µ¿»ç ÃßÃâ
# ko.words <- function(docs){
#   d <- as.character(docs)
#   pos <- paste(SimplePos09(d))
#   extracted <- str_match(pos, '([°¡-ÆR0-9]+)/[NP]')
#   keyword <- extracted[,2]
#   keyword[!is.na(keyword)]
# }
# 

cps<- VCorpus(VectorSource(e))

dtm <- DocumentTermMatrix(cps,
                          control = list(weighting= weightTf))


inspect(dtm)

Docs(table)


t=removeSparseTerms(dtm,0.9999)

inspect(t)

raw.sum=apply(t,1,FUN=sum)
table=t[raw.sum!=0,]


##### ÃÖÀû ÅäÇÈ ¼ö ÃßÁ¤
####### Griffiths2004, Deveaud2014´Â Áö¼ö°ªÀÌ Å¬¼ö·Ï LDA¸ðÇüÀÇ k °ªÀÌ ´õÀûÀýÇÑ ÀáÀçÅäÇÈ °³¼ö
####### CaoJuan2009¿Í Arun2010ÀÇ °æ¿ì Áö¼ö°ªÀÌ ÀÛÀ» ¼ö·Ï LDA¸ðÇüÀÇ k °ªÀÌ ´õ ÀûÀýÇÑ ÀáÀçÅäÇÈ °³¼ö
####### Griffiths2004: ±é½º»ùÇÃ¸µÀÇ ·Î±× ¿ìµµÀÇ Á¶È­ Æò±ÕÀ» ÃÖ´ë·Î ÇÏ´Â k°ª
####### Deveaud2014´Â ÅäÇÈ ºÐÆ÷°£ÀÇ Á¨½¼-»þ³í °Å¸®°¡ ÃÖ´ëÈ­ÇÏ´Â k°ª
####### CaoJuan2009´Â ÅäÇÈ ºÐÆ÷ °£ÀÇ ÄÚ»çÀÎ À¯»çµµ¸¦ °¡Àå ÀÛ°ÔÇÏ´Â k°ª
####### Arun2010Àº  ÅäÇÈ-´Ü¾î Çà·Ä·ÎºÎÅÍ ±¸ÇÑ Æ¯ÀÌ°ª ºÐÆ÷ÀÇ Kullback_liebler divergence°¡ ÃÖ¼ÒÈ­µµµµ·Ï ÇÏ´Â k °ª

result1 <- FindTopicsNumber(
  table,
  topics = seq(from = 10, to =45, by = 5),
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
  method = "Gibbs",
  control = list(seed = 4242),
  mc.cores = 8L,
  verbose = TRUE
)
FindTopicsNumber_plot(result1)
result2 <- FindTopicsNumber(               
  table,
  topics = seq(from = 20, to =35, by = 1),
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
  method = "Gibbs",
  control = list(seed = 4242),
  mc.cores = 8L,
  verbose = TRUE
)

FindTopicsNumber_plot(result2)

#### ÅäÇÈÀÇ ¼ö´Â 28 ~ 30

inspect(dtm)


rownames(dtm) <- paste0(rownames(dtm),"-",data[,1][1:10])

lda_data = LDA(table, k=30, method = "Gibbs", control = list(seed=123,burnin=1000,iter=1000,thin=100))
str(lda_data)

lda_data_term = tidy(lda_data, matrix="beta")


lda_term_top = lda_data_term %>% group_by(topic) %>% top_n(20,beta) %>% ungroup() %>% arrange(topic, -beta)


ggplot(lda_term_top, aes(reorder(term, beta), beta, fill=factor(topic))) + geom_col(show.legend = FALSE) + facet_wrap(~paste("Topic",topic),scales="free")+
  labs(x=NULL, y="Word-Topic Probability (Beta)") + coord_flip()

all_term = data.frame(1:20)
for(i in 1:30){#i=1
  rr = lda_term_top %>% filter(topic==i)
  colnames(rr)=c(paste0('Topic',i),'Keyword','Beta')
  all_term = cbind(all_term,rr[1:20,])
  
  
   
}

write.xlsx(all_term[,2:length(all_term)],'t.xlsx')

lda_data@gamma[1:5,]


lda_doc = tidy(lda_data, matrix='gamma')

topics(lda_data)

lda_doc_1 = lda_doc %>% group_by(document) %>% top_n(1,gamma) %>% ungroup() %>% arrange(document, -gamma)

topics(lda_data)


tr1 = inner_join(tr,lda_doc_1)


tr = data.frame(document = names(topics(lda_data)))
tr = cbind(tr,topics(lda_data))

tr1 = data.frame(document = as.character(1:nrow(data)))
tr1 = cbind(tr1, data)

tr2 = inner_join(tr1,tr)

write.xlsx(tr2, 'class_document.xlsx')
