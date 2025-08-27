import requests
import json
import time

# API 서버 주소 (Colab에서 생성된 ngrok 주소로 교체, 예: "https://your-ngrok-url.ngrok-free.app")
API_URL = "https://a3445d597d22.ngrok-free.app/recommend_outfit"  # 실제 ngrok URL로 업데이트

# styles.csv에서 추출된 아이템 ID와 설명 (여기서는 문서에서 제공된 일부 샘플 사용, 실제로는 전체 CSV 로드 추천)
# 실제 사용 시: import pandas as pd; df = pd.read_csv('styles.csv'); 로 필터링
SAMPLE_ITEMS = {
    # Casual Summer Women (Beach Trip 등)
    59263: "Women Silver Watch (Casual, Winter)",  # Accessory
    21379: "Men Black Track Pants (Casual, Fall)",  # 하지만 Women 시나리오에 맞게 필터
    39386: "Men Blue Jeans (Casual, Summer)",
    53759: "Men Grey T-shirt (Casual, Summer)",
    47957: "Women Blue Handbag (Casual, Summer)",
    59051: "Women Black Flats (Casual, Winter)",
    20099: "Women Green Kurta (Ethnic, Fall)",
    58183: "Women White Handbag (Casual, Summer)",
    3954: "Women Pink T-shirt (Casual, Summer)",
    # Formal Men (Business Meeting 등)
    15970: "Men Navy Blue Shirt (Casual, Fall)",  # Casual이지만 Shirt
    9036: "Men Black Formal Shoes (Formal, Winter)",
    19859: "Men Olive Jacket (Casual, Fall)",  # Outer
    13088: "Men Grey Sweatshirt (Sports, Fall)",  # Adjust
    10579: "Men Purple Shirt (Formal, Fall)",
    4959: "Boys Green T-shirt (Casual, Summer)",
    14392: "Men Black Track Pants (Sports, Fall)",
    28540: "Women Beige Kurta (Ethnic, Summer)",
    1164: "Men Blue T-shirt (Sports, Summer)",
    59435: "Men Black Formal Shoes (Formal, Summer)",
    # Winter Women (Winter Walk 등)
    5649: "Women Black Top (Casual, Winter)",  # 가정
    13090: "Men Navy Blue Tracksuit (Sports, Fall)",
    6394: "Men Black Casual Shoes (Casual, Summer)",
    # Gym Men
    53759: "Men Grey T-shirt (Casual, Summer)",
    1855: "Men Grey T-shirt (Casual, Summer)",
    21379: "Men Black Track Pants (Casual, Fall)",
    15517: "Men Red Casual Shoes (Casual, Fall)",
    5375: "Men White Polo T-shirt (Sports, Summer)",
    14346: "Men Blue Shorts (Sports, Fall)",
    39386: "Men Blue Jeans (Casual, Summer)",
    # Additional for Formal Dinner Women
    5649: "Women Black Dress (Formal, Summer)",  # 가정, 실제 df에서 Dress 선택
    1164: "Women Blue Top (Casual, Summer)",
    19859: "Women Olive Blazer (Formal, Fall)",
    13090: "Women Navy Skirt (Casual, Fall)",
    6394: "Women Black Heels (Formal, Winter)",
    # Summer Vacation Men
    58004: "Men White T-shirt (Casual, Summer)",  # 가정
    2154: "Men Blue Shorts (Casual, Summer)",
    34091: "Girls Black Top (Casual, Summer)",
    55573: "Men Grey Pants (Casual, Fall)",
    15517: "Men Red Shoes (Casual, Fall)",
    6394: "Men Black Shoes (Casual, Summer)",
    9036: "Men Black Formal Shoes (Formal, Winter)",
    13088: "Men Grey Sweatshirt (Sports, Fall)",
    19859: "Men Olive Jacket (Casual, Fall)"
}

# 시나리오 정의: 각 시나리오에 맞는 closet 아이템 ID 리스트 (styles.csv 기반으로 적합한 것 선택)
TEST_SCENARIOS = [
    {
        "name": "시나리오 1: 더운 여름날 데이트 (Beach Trip, Sunny, 32°C, Women)",
        "event": "Beach Trip",
        "temperature": 32.0,
        "condition": "Sunny",
        "gender": "Women",
        "closet": [59263, 47957, 59051, 20099, 58183, 3954, 28540, 34091]  # Summer Casual Women items
    },
    {
        "name": "시나리오 2: 쌀쌀한 가을 비즈니스 미팅 (Business Meeting, Cloudy, 15°C, Men)",
        "event": "Business Meeting",
        "temperature": 15.0,
        "condition": "Cloudy",
        "gender": "Men",
        "closet": [15970, 10579, 9036, 59435, 19859, 13088, 14392, 1164, 10257]  # Formal/Fall Men items
    },
    {
        "name": "시나리오 3: 추운 겨울 공원 산책 (Winter Walk, Snowy, -2°C, Women)",
        "event": "Winter Walk",
        "temperature": -2.0,
        "condition": "Snowy",
        "gender": "Women",
        "closet": [19859, 9036, 13088, 28540, 59051, 20099, 48123]  # Winter/Casual Women with outer
    },
    {
        "name": "시나리오 4: 격식 있는 저녁 식사 (Formal Dinner, Clear, 22°C, Women)",
        "event": "Formal Dinner",
        "temperature": 22.0,
        "condition": "Clear",
        "gender": "Women",
        "closet": [20099, 19859, 6394, 9036, 1164, 13090, 5649]  # Formal/Ethnic Women items
    },
    {
        "name": "시나리오 5: 계절 불일치 (여름에 겨울 옷) (Summer Vacation, Sunny, 35°C, Men)",
        "event": "Summer Vacation",
        "temperature": 35.0,
        "condition": "Sunny",
        "gender": "Men",
        "closet": [53759, 39386, 6394, 15517, 2154, 34091, 58004]  # Mix Summer and some Winter to test mismatch
    },
    {
        "name": "시나리오 6: 운동복 추천 (Gym Workout, Clear, 20°C, Men)",
        "event": "Gym Workout",
        "temperature": 20.0,
        "condition": "Clear",
        "gender": "Men",
        "closet": [53759, 21379, 15517, 1855, 5375, 14346, 39386, 17624]  # Sports/Active Men items
    },
    # 추가 시나리오: 더 다양한 테스트
    {
        "name": "시나리오 7: 캐주얼 산책 (Casual Day Out, Rainy, 18°C, Women)",
        "event": "Casual Day Out",
        "temperature": 18.0,
        "condition": "Rainy",
        "gender": "Women",
        "closet": [3954, 20099, 59051, 58183, 47957, 28540]
    },
    {
        "name": "시나리오 8: 하이킹 (Hiking, Sunny, 25°C, Men)",
        "event": "Hiking",
        "temperature": 25.0,
        "condition": "Sunny",
        "gender": "Men",
        "closet": [53759, 21379, 15517, 39386, 13088, 19859]
    }
]

def test_api(scenario):
    payload = {
        "closet": scenario["closet"],
        "event": scenario["event"],
        "temperature": scenario["temperature"],
        "condition": scenario["condition"],
        "gender": scenario["gender"]
    }
    start_time = time.time()
    response = requests.post(API_URL, json=payload)
    end_time = time.time()
    
    if response.status_code == 200:
        result = response.json()
        print(f"--- 테스트 시나리오: {scenario['name']} ---")
        print(f"상황: {scenario['event']} ({scenario['condition']}, {scenario['temperature']}°C, {scenario['gender']})")
        print(f"옷장 아이템 ID 리스트: {scenario['closet']}")
        if "error" in result:
            print(f"✅ 추천 결과:\n  - 추천 조합을 찾지 못했습니다. 에러: {result['error']}")
        else:
            combo_desc = result['best_combination']['description']
            combo_ids = result['best_combination']['ids']
            explanation = result['explanation']
            score = result['best_score']
            time_taken = end_time - start_time
            print(f"✅ 추천 결과:\n  - 추천 조합: {combo_desc}\n  - 조합 ID: {combo_ids}\n  - 추천 사유: {explanation}\n  - 모델 점수: {score:.4f}\n  - 처리 시간: {time_taken:.2f} 초")
        print("-" * 50, "\n")
    else:
        print(f"❌ API 호출 실패: {response.status_code} - {response.text}")

if __name__ == "__main__":
    for scenario in TEST_SCENARIOS:
        test_api(scenario)