defmodule PokercardRanking do
  @moduledoc """
  Documentation for PokercardRanking.
  """

  @doc """

  ## Examples

      cmd> ./pokercard_ranking --white="2H 3D AD 5S KC"  --black="2C 3H KH 4S 8C"
      Input: Black: 2C 3H KH 4S 8C White: 2H 3D AD 5S KC
      Output: White wins - high card: Ace

  """
  @allCardRankingList %{ "2": [value: 2, name: "2"], "3": [value: 3, name: "3"], "4": [value: 4, name: "4"], "5": [value: 5, name: "5"],
                         "6": [value: 6, name: "6"], "7": [value: 7, name: "7"], "8": [value: 8, name: "8"], "9": [value: 9, name: "9"],
                         "T": [value: 10, name: "10"], "J": [value: 11, name: "Jack"], "Q": [value: 12, name: "Queen"], 
                         "K": [value: 13, name: "King"], "A": [value: 14, name: "Ace"] }

  @allCardTypes %{ "H": "Hearts", "C": "Clubs", "D": "Diamonds", "S": "Spades"}
  @allHandRankingMap %{ "Highcard": 1, "Three of a kind": 2, "Straight": 3, "Flush": 4, "Fullhouse": 5, "Four of a kind": 6, "Straight flush": 7 }

  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "No arguments given, please provide --white=\"\" and --black=\"\""
  end

  def process(options) do
    IO.puts "Input: Black: #{options[:black]} White: #{options[:white]} "
    blackHandMap = listCards("#{options[:black]}")
    whiteHandMap = listCards("#{options[:white]}")
    IO.puts rankPlayers(rankHand(blackHandMap), blackHandMap, rankHand(whiteHandMap), whiteHandMap)
  end

  def rankHand(cardMap) do
    cardTypeCounterList = countTypes(cardMap)
    cond do
     isStraightFlush(cardMap,cardTypeCounterList) -> "Straight flush"
     isFourOfAKind(cardMap)                       -> "Four of a kind"
     isFullHouse(cardMap)                         -> "Fullhouse"
     isFlush(cardTypeCounterList)                 -> "Flush"
     isStraight(cardMap)                          -> "Straight"
     isThreeOfAKind(cardMap)                      -> "Three of a kind"
     true                                         -> "Highcard"
    end
  end

  def countTypes(cardMap) do
    cardTypeCounterList = ["Hearts": 0, "Clubs": 0, "Diamonds": 0, "Spades": 0]
    countTypesRecursive(cardMap, cardTypeCounterList,5)
  end


  def countTypesRecursive(cardMap, cardTypeCounterList, n) when n <= 1 do
    cardType = Map.get(cardMap, n) |> getCardType()
    upCardTypeCounter(cardType,cardTypeCounterList)
  end

  def countTypesRecursive(cardMap, cardTypeCounterList, n) do
    cardType = Map.get(cardMap, n) |> getCardType()
    cardTypeCounterList = upCardTypeCounter(cardType,cardTypeCounterList)
    countTypesRecursive(cardMap,cardTypeCounterList, n-1)
  end

  def getCardType(card) do
    [value: _cardValue, card: _cardID, type: cardType, cardName: _cardName ] = card
    cardType
  end

  def upCardTypeCounter(type,cardTypeCounterList) do
    ["Hearts": heartsCount, "Clubs": clubsCount, "Diamonds": diamondsCount, "Spades": spadesCount]  = cardTypeCounterList
    cond do
      type == "Hearts"   -> ["Hearts": heartsCount+1, "Clubs": clubsCount, "Diamonds": diamondsCount, "Spades": spadesCount]
      type == "Clubs"    -> ["Hearts": heartsCount, "Clubs": clubsCount+1, "Diamonds": diamondsCount, "Spades": spadesCount]
      type == "Diamonds" -> ["Hearts": heartsCount, "Clubs": clubsCount, "Diamonds": diamondsCount+1, "Spades": spadesCount]
      type == "Spades"   -> ["Hearts": heartsCount, "Clubs": clubsCount, "Diamonds": diamondsCount, "Spades": spadesCount+1]
      true -> cardTypeCounterList
    end
  end

  def rankPlayers(p1HandRanking, p1CardMap, p2HandRanking, p2CardMap) do
    p1RankValue = Map.get(@allHandRankingMap, :"#{p1HandRanking}")
    p2RankValue = Map.get(@allHandRankingMap, :"#{p2HandRanking}")

    cond do
      p1RankValue > p2RankValue   -> "Output: Black wins - #{p1HandRanking}"
      p2RankValue > p1RankValue   -> "Output: White wins - #{p2HandRanking}"
      p1RankValue === p2RankValue -> highCardCalculation(p1CardMap, p2CardMap)
      true                        -> "Output: Error"
    end
  end

  def highCardCalculation(p1CardMap, p2CardMap) do
    p1HighCard = Map.get(p1CardMap, 1)
    p2HighCard = Map.get(p2CardMap, 1)
    
    p1HighCard = highestCardCalculation(p1HighCard, p1CardMap, 5)
    p2HighCard = highestCardCalculation(p2HighCard, p2CardMap, 5)

    [value: p1HighCardValue, card: _p1HighCardID, type: _p1HighCardType, cardName: p1HighCardName ] = p1HighCard
    [value: p2HighCardValue, card: _p2HighCardID, type: _p2HighCardType, cardName: p2HighCardName ] = p2HighCard

    cond do
      p1HighCardValue > p2HighCardValue  -> "Output: Black wins - high card: #{p1HighCardName}"
      p2HighCardValue > p1HighCardValue  -> "Output: White wins - high card: #{p2HighCardName}"
      p2HighCardValue == p1HighCardValue -> "Output: Tie"
      true                               -> "Output: Error" #should be unreachable...
    end
  end

  def highestCardCalculation(highestCard, cardMap, n) when n <= 2 do
    Map.get(cardMap, n) |> processHighestCard(highestCard)
  end

  def highestCardCalculation(highestCard, cardMap, n) do
    Map.get(cardMap, n) 
    |> processHighestCard(highestCard)
    |> highestCardCalculation(cardMap, n - 1)
  end

  def processHighestCard(currentCard, previousCard) do
    [value: currentCardValue, card: _currentCardID, type: _currentCardType, cardName: _currentCardName ] = currentCard 
    [value: previousCardValue, card: _previousCardID, type: _previousCardType, cardName: _previousCardName ] = previousCard
    cond do
      currentCardValue > previousCardValue -> currentCard
      true                                 -> previousCard
    end
  end

  def isStraightFlush(cardMap, cardTypeCounterList) do
    cond do
      (isStraight(cardMap) && isFlush(cardTypeCounterList)) == true -> true
      true                                                          -> false
    end
  end
  
  def isFourOfAKind(cardMap) do
    [firstCardCounter | [secondCardCounter | _leftovers ]] = countCards(cardMap)
    
    firstCardCounterValue = elem(firstCardCounter,1)
    secondCardCounterValue = elem(secondCardCounter,1)

    cond do
      firstCardCounterValue  == 4 -> true
      secondCardCounterValue == 4 -> true
      true                        -> false
    end
  end
  
  def isFullHouse(cardMap) do
    [firstCardCounter | [secondCardCounter | _leftovers ]] = countCards(cardMap)
    
    firstCardCounterValue = elem(firstCardCounter,1)
    secondCardCounterValue = elem(secondCardCounter,1)
    
    cond do
      ((firstCardCounterValue  == 3) && (secondCardCounterValue == 2)) -> true
      ((firstCardCounterValue  == 2) && (secondCardCounterValue == 3)) -> true
      true                                                             -> false
    end
  end
  
  def isFlush(cardTypeCounterList) do
    ["Hearts": heartsCount, "Clubs": clubsCount, "Diamonds": diamondsCount, "Spades": spadesCount]  = cardTypeCounterList
    cond do
      heartsCount   == 5 -> true
      clubsCount    == 5 -> true
      diamondsCount == 5 -> true
      spadesCount   == 5 -> true
      true               -> false
    end
  end
  
  def isStraight(cardMap) do
    sortedKeyMap = Map.to_list(cardMap) |> List.keysort(1)

    [firstCard | [secondCard | [thirdCard | [ fourthCard | [ fifthCard | _possibleLeftOvers ]]]]] = sortedKeyMap  
    
    firstCard = elem(firstCard,1)
    secondCard = elem(secondCard,1)
    thirdCard = elem(thirdCard,1)
    fourthCard = elem(fourthCard,1)
    fifthCard = elem(fifthCard,1)

    isFollowup = areCardsFollowUps(firstCard, secondCard, true)
    isFollowup = areCardsFollowUps(secondCard, thirdCard, isFollowup)
    isFollowup = areCardsFollowUps(thirdCard, fourthCard, isFollowup)
    areCardsFollowUps(fourthCard, fifthCard, isFollowup)
  end

  def areCardsFollowUps(cardOne, cardTwo, followUp) do
    [value: cardOneValue, card: _cardTwoID, type: _cardOneType, cardName: _cardOneName ] = cardOne
    [value: cardTwoValue, card: _cardTwoID, type: _cardTwoType, cardName: _cardTwoName ] = cardTwo
    cond do
      followUp == false              -> false
      cardOneValue+1 == cardTwoValue -> true
      true                           -> false
    end
  end
  
  def isThreeOfAKind(cardMap) do
    [firstCardCounter | [secondCardCounter | [ thirdCardCounter | _leftovers ]]] = countCards(cardMap)
    
    firstCardCounterValue = elem(firstCardCounter,1)
    secondCardCounterValue = elem(secondCardCounter,1)
    thirdCardCounterValue = elem(thirdCardCounter,1)
    
    cond do
      firstCardCounterValue  == 3 -> true
      secondCardCounterValue == 3 -> true
      thirdCardCounterValue  == 3 -> true                                                            
      true                        -> false
    end
  end

  def countCards(cardMap) do
    sortedKeyMap = Map.to_list(cardMap) |> List.keysort(1)

    [firstCard | [secondCard | [thirdCard | [ fourthCard | [ fifthCard | _possibleLeftOvers ]]]]] = sortedKeyMap 

    firstCard = elem(firstCard,1)
    secondCard = elem(secondCard,1)
    thirdCard = elem(thirdCard,1)
    fourthCard = elem(fourthCard,1)
    fifthCard = elem(fifthCard,1)

    [value: firstCardValue, card: _currentCardID, type: _currentCardType, cardName: _currentCardName ] = firstCard 
    [value: secondCardValue, card: _currentCardID, type: _currentCardType, cardName: _currentCardName ] = secondCard 
    [value: thirdCardValue, card: _currentCardID, type: _currentCardType, cardName: _currentCardName ] = thirdCard 
    [value: fourthCardValue, card: _currentCardID, type: _currentCardType, cardName: _currentCardName ] = fourthCard 
    [value: fifthCardValue, card: _currentCardID, type: _currentCardType, cardName: _currentCardName ] = fifthCard
    
    cardValuesList = [firstCardValue,secondCardValue,thirdCardValue,fourthCardValue,fifthCardValue]

    firstCardCounter = Enum.count(cardValuesList, fn(x) -> matchValue(x, firstCardValue) == 0 end)
    secondCardCounter = Enum.count(cardValuesList, fn(x) -> matchValue(x, secondCardValue) == 0 end)
    thirdCardCounter = Enum.count(cardValuesList, fn(x) -> matchValue(x, thirdCardValue) == 0 end)
    fourthCardCounter = Enum.count(cardValuesList, fn(x) -> matchValue(x, fourthCardValue) == 0 end)
    fifthCardCounter = Enum.count(cardValuesList, fn(x) -> matchValue(x, fifthCardValue) == 0 end)

    cardCountedList = [ "#{firstCardValue}": firstCardCounter, "#{secondCardValue}": secondCardCounter, 
    "#{thirdCardValue}": thirdCardCounter, "#{fourthCardValue}": fourthCardCounter, "#{fifthCardValue}": fifthCardCounter ]
    Enum.dedup(cardCountedList)
  end

  def matchValue(x,card) do
    cond do
      x == card -> 0
      true      -> 1
    end
  end

  def listCards(hand) do
    cardListStrings = String.split("#{hand}"," ")

    card1 = Enum.at(cardListStrings,0)
    [value: card1Value, name: card1Name] = Map.get(@allCardRankingList, :"#{String.at(card1,0)}")
    card1Type  = Map.get(@allCardTypes, :"#{String.at(card1,1)}")

    card2 = Enum.at(cardListStrings,1)
    [value: card2Value, name: card2Name] = Map.get(@allCardRankingList, :"#{String.at(card2,0)}")
    card2Type  = Map.get(@allCardTypes, :"#{String.at(card2,1)}")

    card3 = Enum.at(cardListStrings,2)
    [value: card3Value, name: card3Name] = Map.get(@allCardRankingList, :"#{String.at(card3,0)}")
    card3Type  = Map.get(@allCardTypes, :"#{String.at(card3,1)}")
    
    card4 = Enum.at(cardListStrings,3)
    [value: card4Value, name: card4Name] = Map.get(@allCardRankingList, :"#{String.at(card4,0)}")
    card4Type  = Map.get(@allCardTypes, :"#{String.at(card4,1)}")
    
    card5 = Enum.at(cardListStrings,4)
    [value: card5Value, name: card5Name] = Map.get(@allCardRankingList, :"#{String.at(card5,0)}")
    card5Type  = Map.get(@allCardTypes, :"#{String.at(card5,1)}")

    cardMap = Map.new()
    cardMap = Map.put_new(cardMap,1, [value: card1Value, card: "#{card1}", type: "#{card1Type}", cardName: "#{card1Name}" ])
    cardMap = Map.put_new(cardMap,2, [value: card2Value, card: "#{card2}", type: "#{card2Type}", cardName: "#{card2Name}" ])
    cardMap = Map.put_new(cardMap,3, [value: card3Value, card: "#{card3}", type: "#{card3Type}", cardName: "#{card3Name}" ])
    cardMap = Map.put_new(cardMap,4, [value: card4Value, card: "#{card4}", type: "#{card4Type}", cardName: "#{card4Name}" ])
    Map.put_new(cardMap,5, [ value: card5Value, card: "#{card5}", type: "#{card5Type}", cardName: "#{card5Name}" ])
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [arg: :string]
    )
    options
  end
end
