Original App Design Project - README Template
===

# Breaking Barriers

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Language barriers are a very common issue when it comes to traveling to getting to know someone who doesn’t speak the same language as you. Breaking Barriers is designed to act as a real time conversation translator. Two people would have a normal conversation and speak into a phone one at a time. As one person speaks into it, whatever they said would be translated and outputted in the others persons desired language while also displaying the text on screen. Then from there, they can just talk back in forth as any other person would do in a normal conversation.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Lifestyle
- **Mobile:** Section for natural conversation, section for scanning documents/text and a section for day to day translation of words.
- **Story:** Use a natural language processing API. Would be used to eliminate language barriers. One person would speak then that would get translated in the other language then vice-versa. Would try and make for a seamless conversation
- **Market:** This could be for anybody that wants to be able to break language barriers. Could also be used to learn as you can see what is being translated.
- **Habit:** This has the potential to be habit forming. If they are in a situation where they need an on the go conversion translator this can be it.
- **Scope:** Integrate Google language processing API as well with any other natural language processing API.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can talk into the microphone and outputted in any other language
* User can take a picture/scan a document and have that translated into their desired language
* User can type something that they want a translation for in a certain language
* Text is displayed on screen each time after every person has talked
* There is a button mic for either person to tap when they want to talk
* User can change between which langauges want to be translated for
* User us able to sign in or sign up


**Optional Nice-to-have Stories**

* User can favorite certain phrases that they would like to be saved and used on the go
* Text is displayed as the user is speaking into it
* There is a universal mic button to press that would detect who and in what language is being spoken
* In landscape mode the UI would change to a more 1 on 1 interface mode
* There is a dictionary option to look up a word and what it means
* Messaging system where you can send a message to someone and they will receive it in their language.

### 2. Screen Archetypes

* Login / Sign Up
   * User is able sign up or login to their account
* Stream
   * User can talk into the microphone and outputted in any other language
   * Text is displayed on screen each time after every person has talked
* Creation
    * User can take a picture/scan a document and have that translated into their desired language
    * User can type something that they want a translation for in a certain language

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Conversation
* Camera/Scan
* Favorites/Saved
* Messages
* Profile

**Flow Navigation** (Screen to Screen)

* [list first screen here]
   * [list screen navigation here]
   * ...
* [list second screen here]
   * [list screen navigation here]
   * ...

## Wireframes
<img src="https://i.imgur.com/B4yFvN3.jpg" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
### Models
#### Message

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the user message (default field) |
   | author        | Pointer to User| message author |
   | text       | String   | message author wrote |
   | directedTo | Pointer to User   | unique id for who the message was for |
   | createdAt     | DateTime | date when message is created (default field) |
   | updatedAt     | DateTime | date when message is last updated (default field) |
### Networking
#### List of network requests by screen
   - Conversation Screen
      - (POST) Detecting language of text
         ```objective-c
         ```
      - (POST) Translate text to desired language
          ```objective-c
         [translationAPI translateText:@"Hello. How are you?"
          usingSourceLanguage:nil
          destinationLanguage:[[GTLanguage alloc] initWithLanguageCode:@"es"]
        withCompletionHandler:^(NSArray *translations, NSError *error) {
              if (error) {
                 NSLog(@"error: %@", error);
              } else {
                 NSLog(@"translations: %@", translations);
              }
          }];
         ```
   - Create Post Screen
      - (Create/POST) Create a new post object
   - Profile Screen
      - (Read/GET) Query logged in user object
      - (Update/PUT) Update user profile image
#### [OPTIONAL:] Existing API Endpoints
##### An API Google Cloud Translation
- Base URL - [https://translation.googleapis.com](https://translation.googleapis.com)

   HTTP Verb | Endpoint | Description
   ----------|----------|------------
    `POST`    | /language/translate/v2 | translates input text, returning translated text
    `POST`    | /language/translate/v2/detect | detects the language of text within request
