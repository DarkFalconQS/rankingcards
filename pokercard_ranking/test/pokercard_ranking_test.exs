defmodule PokercardRankingTest do
  use ExUnit.Case
  doctest PokercardRanking
  import PokercardRanking

  test "isFlush" do
    isFlushTrue = listCards("2H 3H 4H 5H 6H") |> countTypes |> isFlush
    assert isFlushTrue == true
  end

  test "isNoFlush" do
    isFlushTrue = listCards("2H 3H 4S 5H 6H") |> countTypes |> isFlush
    assert isFlushTrue == false
  end

  test "isStraightFlush" do
    cardMap = listCards("2H 3H 4H 5H 6H")
    typesCounterList = countTypes(cardMap)
    isStraightFlush = isStraightFlush(cardMap, typesCounterList)
    assert isStraightFlush == true
  end

  test "isNoStraightFlush" do
    cardMap = listCards("2H 3H 4H 5H 7H")
    typesCounterList = countTypes(cardMap)
    isStraightFlush = isStraightFlush(cardMap, typesCounterList)
    assert isStraightFlush == false
  end

  test "isFourOfAKind" do
    isFourOfAKind = listCards("2H 2D 2S 2A 7H") |> isFourOfAKind
    assert isFourOfAKind == true
  end

  test "isNoFourOfAKind" do
    isFourOfAKind = listCards("2H 2D 3S 2A 7H") |> isFourOfAKind
    assert isFourOfAKind == false
  end

  test "isFullHouse" do
    isFullHouse = listCards("2H 2D 3S 3A 3H") |> isFullHouse
    assert isFullHouse == true
  end

  test "isNoFullHouse" do
    isFullHouse = listCards("2H 2D 3S 5A 3H") |> isFullHouse
    assert isFullHouse == false
  end

  test "isStraight" do
    isStraight = listCards("TH JD KS QS AH") |> isStraight
    assert isStraight == true
  end

  test "isNoStraight" do
    isStraight = listCards("TH JD KS 6S AH") |> isStraight
    assert isStraight == false
  end

  test "isThreeOfAKind" do
    isThreeOfAKind = listCards("TH TD TS 6S AH") |> isThreeOfAKind
    assert isThreeOfAKind == true
  end

  test "isNoThreeOfAKind" do
    isThreeOfAKind = listCards("TH JD TS 6S AH") |> isThreeOfAKind
    assert isThreeOfAKind == false
  end

  test "highCardCalculationP2Winner" do
    p1Map = listCards("TH 8D 9S 6S QH")
    p2Map = listCards("TH JD QS AS KH")
    winnerIs = highCardCalculation(p1Map, p2Map)
    assert winnerIs == "Output: White wins - high card: Ace"
  end

  test "highCardCalculationP1Winner" do
    p1Map = listCards("TH JD QS AS KH")
    p2Map = listCards("TH 8D 9S 6S QH")
    winnerIs = highCardCalculation(p1Map, p2Map)
    assert winnerIs == "Output: Black wins - high card: Ace"
  end

  test "highCardCalculationTie" do
    p1Map = listCards("TH JD QS AS KH")
    p2Map = listCards("TH 8D 9S 6S AH")
    winnerIs = highCardCalculation(p1Map, p2Map)
    assert winnerIs == "Output: Tie"
  end

  test "moreHandPossibilitiesStraightFlush" do
    p1Map = listCards("2H 3D 5S 9C KD")
    p2Map = listCards("2D 3D 4D 5D 6D")
    winnerIs = rankPlayers(rankHand(p1Map), p1Map, rankHand(p2Map), p2Map)
    assert winnerIs == "Output: White wins - Straight flush"
  end

  test "moreHandPossibilitiesFullHouse" do
    p1Map = listCards("2H 2D 3S 3C 3D")
    p2Map = listCards("2D 3D 4D 5D 7D")
    winnerIs = rankPlayers(rankHand(p1Map), p1Map, rankHand(p2Map), p2Map)
    assert winnerIs == "Output: Black wins - Fullhouse"
  end

  test "moreHandPossibilities2xFullHouse" do
    p1Map = listCards("2H 2D 3S 3C 3D")
    p2Map = listCards("2D 2S 5C 5H 5A")
    winnerIs = rankPlayers(rankHand(p1Map), p1Map, rankHand(p2Map), p2Map)
    assert winnerIs == "Output: White wins - high card: 5"
  end

  test "moreHandPossibilitiesFourOfAKind" do
    p1Map = listCards("2H 2D 2S 2A 5D")
    p2Map = listCards("2D 2S 5C 5H 5A")
    winnerIs = rankPlayers(rankHand(p1Map), p1Map, rankHand(p2Map), p2Map)
    assert winnerIs == "Output: Black wins - Four of a kind"
  end

  # Examples:
  # Input: Black: 2H 3D 5S 9C KD White: 2C 3H 4S 8C AH
  # Output: White wins - high card: Ace

  test "example1" do
    p1Map = listCards("2H 3D 5S 9C KD")
    p2Map = listCards("2C 3H 4S 8C AH")
    winnerIs = rankPlayers(rankHand(p1Map), p1Map, rankHand(p2Map), p2Map)
    assert winnerIs == "Output: White wins - high card: Ace"
  end

  # Input: Black: 2H 4S 4C 3D 4H White: 2S 8S AS QS 3S
  # Output: White wins - flush

  test "example2" do
    p1Map = listCards("2H 4S 4C 3D 4H")
    p2Map = listCards("2S 8S AS QS 3S")
    winnerIs = rankPlayers(rankHand(p1Map), p1Map, rankHand(p2Map), p2Map)
    assert winnerIs == "Output: White wins - Flush"
  end

  # Input: Black: 2H 3D 5S 9C KD White: 2C 3H 4S 8C KH
  # Output: Black wins - high card: 9

  test "example3" do
    p1Map = listCards("2H 3D 5S 9C KD")
    p2Map = listCards("2C 3H 4S 8C KH")
    winnerIs = rankPlayers(rankHand(p1Map), p1Map, rankHand(p2Map), p2Map)
    assert winnerIs == "Output: Tie"
  end

  # Input: Black: 2H 3D 5S 9C KD White: 2D 3H 5C 9S KH
  # Output: Tie

  test "example4" do
    p1Map = listCards("2H 3D 5S 9C KD")
    p2Map = listCards("2D 3H 5C 9S KH")
    winnerIs = rankPlayers(rankHand(p1Map), p1Map, rankHand(p2Map), p2Map)
    assert winnerIs == "Output: Tie"
  end
end
