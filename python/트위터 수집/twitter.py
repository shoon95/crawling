import json
from os import error
import requests
import re
import pandas as pd
import time
from datetime import datetime, timedelta
from collections import defaultdict

column1 = ['user_id','username','name','account_create_date','description','follwers_count',
            'followings_count','tweets_count','media_count','favourites_count','nick_len','nick_count_Q']

column2 = ['id','conversation_id','created_at','date','time','tweet','language',
            'mentions','urls','photos','replies_count','retweets_count','likes_count',
            'hashtags','link','quote_url','video','thumbnail',
            'retweet_user_id','retweet_username','retweet_id','retweet_date',
            'tweet_len','tweet_count_Q',
            'tweet_count_space','space_div_len','last_word','search_word',
            'noun_div_pos','tweet_type','y']


outputColumns = []
outputColumns.extend(column2)
outputColumns.extend(column1)


class CountInfo:
    def __init__(self):
        self.rest_id = ""
        self.screen_name = ""
        self.name = ""
        self.created_at = ""
        self.description = ""
        self.followers_count = ""
        self.friends_count = ""
        self.statuses_count = ""
        self.media_count = ""
        self.favourites_count = ""

        self.nick_len = ""
        self.nick_count_Q = ""

class Tweet2:
    def __init__(self):
        self.url = ""    
        self.id_str = ""
        self.conversation_id_str = ""
        self.full_text = ""
        self.created_at = ""
        self.video = False
        self.retweet_count = ""
        self.reply_count = ""
        self.favorite_count = ""
        self.quote_count = ""
        self.thumbnail = ""
        self.photos = []
        self.urls = []
        self.hashTags = []
        self.mentions = []
        self.lang = ""
        self.retweeted = False
        self.retweet = False
        self.quote_url = ""
        self.retweet_id = "" 
        self.retweet_user_id = ""
        self.retweet_username = ""
        self.retweet_date = ""
        self.in_reply_to_status_id_str = "" # ReplyTweetId
        self.in_reply_to_user_id_str = "" # ReplyUserId
        self.in_reply_to_screen_name = "" # ReplyUserName 
        self.source = ""
        self.lastWord = False
        self.is_quote_status = False

        self.tweet_len = ""
        self.tweet_count_Q = ""
        self.tweet_count_space = ""
        self.space_div_len = ""
        self.last_word = ""
        self.search_word = ""
        self.noun_div_pos = ""
        self.y = ""
        self.tweet_type = ""

a_list = ["섹스파트너","섹파","애인대행","애인모드","조건만남","출장대행","출장샵",
 "출장아가씨","출장안마","풀싸롱","콜걸","오피걸","풀싸롱","셔츠룸","레깅스룸",
 "란제리룸","란제리노래방","룸야구장"]
b_list = ["펠라","질싸","핸플","사까시","역립"]
d = defaultdict(list)
a_dict = {s: 'a' for s in a_list}
b_dict = {s: 'b' for s in b_list}
d.update(a_dict)
d.update(b_dict)

def ConvertDateTime(created_at):
    timeText = time.strftime('%Y-%m-%d %H:%M:%S', time.strptime(created_at, '%a %b %d %H:%M:%S +0000 %Y'))
    return datetime.strptime(timeText, '%Y-%m-%d %H:%M:%S') + timedelta(hours=9)


def Send(url, header):
    headers = {}

    if header == True:
        headers = { "Authorization" : "Bearer " + bearer, "x-guest-token" : guestId}
        # print(headers)
    
    response = requests.get(url, headers=headers, timeout=120)

    return response

def SetGuestId(userName):
    url = "https://twitter.com/" + userName
    html = Send(url, False)
    # print(html.cookies['guest_id'])
    try:
        startText = "document.cookie = decodeURIComponent(\"gt="
        stringStart = html.text.find(startText)
        stringEnd = html.text.find(';', stringStart)
        global guestId
        gid = html.text[stringStart + len(startText):stringEnd]
        guestId = gid
    except:
        pass

def GetCountInfo(username):
    baseUrl = "https://twitter.com/i/api/graphql/Vf8si2dfZ1zmah8ePYPjDQ/UserByScreenNameWithoutResults?variables=%7B%22screen_name%22%3A%22" + username + "%22%2C%22withHighlightedLabel%22%3Atrue%7D"
    
    html = Send(baseUrl, True)
    # print(html.text)

    infoData = json.loads(html.text)
    if infoData.get("data") == None:
        return None
    if infoData["data"].get("user") == None:
        return None
    if infoData["data"]["user"].get("legacy") == None:
        return None

    # countInfo = CountInfo(infoData["data"]["user"]["legacy"], infoData["data"]["user"]["rest_id"])

    legacy = infoData["data"]["user"]["legacy"]
    countInfo = CountInfo()
    countInfo.rest_id = infoData["data"]["user"]["rest_id"]
    countInfo.screen_name = legacy["screen_name"]
    countInfo.name = legacy["name"]
    countInfo.created_at = ConvertDateTime(legacy["created_at"])
    countInfo.description = legacy["description"].replace("\n", " ")
    countInfo.followers_count = legacy["followers_count"]
    countInfo.friends_count = legacy["friends_count"]
    countInfo.statuses_count = legacy["statuses_count"]
    countInfo.media_count = legacy["media_count"]
    countInfo.favourites_count = legacy["favourites_count"]

    countInfo.nick_len = len(countInfo.name)
    countInfo.nick_count_Q = GetQustionMarkCount(countInfo.name)

    return countInfo

def GetTweets2(username, userId, search_word, y):
    limit = "11"
    baseUrl = "https://twitter.com/i/api/graphql/L15nBTK_B0O_NMEpnsH4MQ/UserTweets?variables=%7B%22userId%22%3A%22" + userId + "%22%2C%22count%22%3A" + limit + "%2C%22withHighlightedLabel%22%3Atrue%2C%22withTweetQuoteCount%22%3Atrue%2C%22includePromotedContent%22%3Atrue%2C%22withTweetResult%22%3Afalse%2C%22withReactions%22%3Afalse%2C%22withUserResults%22%3Afalse%2C%22withVoice%22%3Afalse%2C%22withNonLegacyCard%22%3Atrue%2C%22withBirdwatchPivots%22%3Afalse%7D"

    html = Send(baseUrl, True)
    tweetData = json.loads(html.text)
    if tweetData.get("data") == None:
        return None

    if tweetData["data"]["user"]["result"]["__typename"] == "UserUnavailable":
        return None

    list = tweetData["data"]["user"]["result"]["timeline"]["timeline"]["instructions"][0]["entries"]

    tweets = []
    for l in list:
        if l["content"].get("itemContent") == None: continue
        if l["content"]["itemContent"].get("tweet") == None: continue
        if l["content"]["itemContent"]["tweet"].get("legacy") == None: continue

        t = l["content"]["itemContent"]["tweet"]["legacy"]
        

        tweet = Tweet2()
        tweet.id_str = t["id_str"]
        tweet.url = "https://twitter.com/" + str(username) + "/status/" + str(tweet.id_str)
        tweet.conversation_id_str = t["conversation_id_str"]
        tweet.full_text = t["full_text"].replace("\n", " ")
        tweet.retweet_count = t["retweet_count"]
        tweet.reply_count = t["reply_count"]
        tweet.favorite_count = t["favorite_count"]
        tweet.quote_count = t["quote_count"]
        tweet.in_reply_to_status_id_str = t.get('in_reply_to_status_id_str', '')
        tweet.in_reply_to_user_id_str = t.get('in_reply_to_user_id_str', '')
        tweet.in_reply_to_screen_name = t.get('in_reply_to_screen_name', '')
        tweet.source = t["source"]
        tweet.is_quote_status = t["is_quote_status"]
        tweet.lang = t["lang"]
        tweet.created_at = ConvertDateTime(t["created_at"])

        tweet.tweet_len = len(tweet.full_text)
        tweet.tweet_count_space = tweet.full_text.count(" ")
        tweet.space_div_len = tweet.tweet_count_space / tweet.tweet_len
        tweet.search_word = search_word
        tweet.y = y
        tweet.tweet_type = d.get(search_word, "c")
        
        # Todo
        tweet.tweet_count_Q = GetQustionMarkCount(tweet.full_text)
        # tweet.noun_div_pos = 

        if t.get("entities") != None:
            entities = t["entities"]
            
            if (entities.get("hashtags") != None):
                hashTagArray = entities["hashtags"]
                for hashTag in hashTagArray:
                    tweet.hashTags.append(hashTag["text"])
            

            if entities.get("user_mentions") != None:
            
                mentionArray = entities["user_mentions"]
                for mention in mentionArray:
                    tweet.mentions.append(mention["screen_name"])

            
            if entities.get("urls") != None:
                urlArray = entities["urls"]
                for url in urlArray:
                    if url["url"] not in tweet.urls:
                        tweet.urls.append(url["url"])

            
            if entities.get("media") != None:
                mediaArray = entities["media"]
                for media in mediaArray:
                    if str(media["expanded_url"]).count("/video") > 0:
                        tweet.video = True

                    if (tweet.video == False):
                        tweet.photos.append(media["media_url_https"])
                        tweet.thumbnail = media["url"]

            if t.get("retweeted_status") != None:
           
                retweetedStatus = t["retweeted_status"]
                tweet.retweet_id = retweetedStatus["rest_id"]
                tweet.retweet = True
                
                if retweetedStatus.get("core") != None and retweetedStatus["core"].get("user") and retweetedStatus["core"]["user"].get("legacy") != None:
                    user = retweetedStatus["core"]["user"]
                    tweet.retweet_user_id = user["rest_id"]
                    tweet.retweet_username = user["legacy"]["screen_name"]

                if retweetedStatus.get("legacy") != None:
                    retweetedLegacy = retweetedStatus["legacy"]
                    tweet.RetweetDate = ConvertDateTime(retweetedLegacy["created_at"])
                
            if tweet.is_quote_status:
                if t.get("quoted_status_permalink") and t["quoted_status_permalink"].get("expanded"):
                    tweet.quote_url = t["quoted_status_permalink"]["expanded"]

            firstRegex = re.compile("[a-zA-Z]")
            endRegex = re.compile("[0-9]")

            try:
                word1 = tweet.full_text.replace("\n", "")
                lastInext = word1.rindex(" ")
                word = word1[lastInext + 1:]
                firstWord = word[0:1]
                lastWord = word[len(word) - 1 : len(word)]
                if firstRegex.match(firstWord) and endRegex.match(lastWord):
                    tweet.lastWord = True
            except:
                if len(tweet.full_text) > 0:
                    firstWord = tweet.full_text[0:1]
                    lastWord = tweet.full_text[len(tweet.full_text) - 1 : len(tweet.full_text)]
                    
                    if firstRegex.match(firstWord) and endRegex.match(lastWord):
                        tweet.lastWord = True

        tweets.append(tweet)

    return tweets

def GetQustionMarkCount(data_string):
    data_string1 = data_string.replace("?", "")
    data_string949 = data_string1.encode('CP949', 'replace').decode('CP949')

    return data_string949.count("?")

def ConvertDateTime(created_at):
    timeText = time.strftime('%Y-%m-%d %H:%M:%S', time.strptime(created_at, '%a %b %d %H:%M:%S +0000 %Y'))

    return datetime.strptime(timeText, '%Y-%m-%d %H:%M:%S') + timedelta(hours=9)

def ExportData(tweet,account_info):
    global df
    if tweet :
        for t in tweet:
            new = {}
            # # tweet information
            new['id'] = t.id_str
            new['conversation_id'] = t.conversation_id_str
            new['created_at'] = t.created_at
            string_ = str(t.created_at)
            new['date'] = string_[:10]
            new['time'] = string_[11:]
            # new['user_id'] = account_info.rest_id
            # new['username'] = account_info.screen_name
            # new['name'] = account_info.name
            new['tweet'] = t.full_text
            new['language'] = t.lang
            new['mentions'] = t.mentions
            new['urls'] = t.urls
            new['photos'] = t.photos
            new['replies_count'] = t.reply_count
            new['retweets_count'] = t.retweet_count
            new['likes_count'] = t.favorite_count
            new['hashtags'] = t.hashTags
            new['link'] = t.url
            new['quote_url'] = t.quote_url
            new['video'] = t.video
            new['thumbnail'] = t.thumbnail
            new['tweet_len'] = t.tweet_len
            # new['reply_to'] = t.~
            new['retweet_user_id'] = t.retweet_user_id
            new['retweet_username'] = t.retweet_username
            new['retweet_date'] = t.retweet_date
            new['tweet_count_Q'] = t.tweet_count_Q
            new['tweet_count_space'] = t.tweet_count_space
            new['space_div_len'] = t.space_div_len
            new['last_word'] =  t.lastWord
            new['search_word'] = t.search_word
            new['noun_div_pos'] = 0
            new['tweet_type'] = t.tweet_type
            new['y'] = t.y

            # account info
            new['user_id'] = account_info.rest_id
            new['username'] = account_info.screen_name
            new['name'] = account_info.name
            new['account_create_date'] = account_info.created_at
            new['description'] = account_info.description
            new['follwers_count'] = account_info.followers_count
            new['followings_count'] = account_info.friends_count
            new['tweets_count'] = account_info.statuses_count
            new['media_count'] = account_info.media_count
            new['favourites_count'] = account_info.favourites_count
            new['nick_len'] = account_info.nick_len
            new['nick_count_Q'] = account_info.nick_count_Q
         
            
            df = df.append(new,ignore_index = True)


     

# test
if __name__ == '__main__':

    df = pd.DataFrame(columns= outputColumns)
    
    bearer = "AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA"
    guestId = ""
    # username = "Suzy"
    user_dict = defaultdict(int)
    dataset = pd.read_csv('./성매매광고트윗_데이터셋.csv', encoding='CP949')
    # dataset = pd.read_csv('data/DataSet.csv', encoding='CP949')
    
    # a,b 유형은 d dictionanary안에 있음.
    # for i in range(25):
    for i in range(len(dataset)):
        print(i)
        tmp = dataset.iloc[i,]
        flag = False

        y = tmp['y']
        name = tmp['name']
        username = tmp['username']
        search_word = tmp['search_word']

        # 트윗조건
        if (y == 1) & (tmp['noun_div_pos'] >= 0.75) & (tmp['last_word']) &(len(tmp['photos'].split(','))):
            # 크롤링 안한 것에 대해서만 
            if user_dict[username] == 0 :
                flag = True
                user_dict[username] = 1

        # 일반 트윗 조건
        elif (y == 0) & (tmp['noun_div_pos'] < 0.7) & (tmp['last_word']):
            if user_dict[username] == 0 :
                flag = True
                user_dict[username] = 1
        
        if flag :
            retry = 0
            switchWhile = True
            while switchWhile:
                try:
                    SetGuestId(username)
                    countInfo = GetCountInfo(username)
                    if countInfo:
                        tweet_list = GetTweets2(username, countInfo.rest_id, search_word, y)

                    switchWhile = False
                except Exception as e:
                    retry = retry + 1
                    print('retry:{}, username:{}'.format(retry, username))
                    print('Exception', e)
                    time.sleep(1 * 60)
            
                if countInfo != None and tweet_list != None:
                    ExportData(tweet_list,countInfo)
    df.columns = outputColumns
    df.to_csv('test_2.csv',encoding='CP949', errors="replace",index = False)