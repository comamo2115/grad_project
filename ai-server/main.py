# FastAPI 추론 서버 전체 코드 (최종본)
# 이 코드를 'main.py' 라는 이름의 파일로 저장하세요.

import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from peft import PeftModel # PEFT 모델을 불러오기 위해 추가
from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn
import os

# --- 1. 데이터 모델 정의 (Pydantic) ---
# API 요청(Request)과 응답(Response)의 형식을 미리 정의합니다.
class RecommendRequest(BaseModel):
    closet: list[str]
    weather: str
    schedule: str

class RecommendResponse(BaseModel):
    recommendation: str

# --- 2. 모델 로드 (애플리케이션 시작 시 1회 실행) ---
# 베이스 모델과 Colab에서 훈련시킨 어댑터 모델의 ID를 명확히 분리합니다.
base_model_id = "google/gemma-2b-it"
adapter_model_id = "luisastre/gemma-fashion-recommender-adapter-v1" 

# Hugging Face 인증 토큰
HF_TOKEN = "여기에-허깅페이스-액세스-토큰-붙여넣기"

print(f"베이스 모델 '{base_model_id}'을 로드합니다...")

# 토크나이저는 베이스 모델의 것을 사용합니다.
tokenizer = AutoTokenizer.from_pretrained(
    base_model_id,
    token=HF_TOKEN
)

# 먼저 원본 베이스 모델을 로드합니다.
# --- 최종 수정점: torch_dtype을 float32로 변경하여 안정성 확보 ---
base_model = AutoModelForCausalLM.from_pretrained(
    base_model_id,
    token=HF_TOKEN,
    torch_dtype=torch.float32, # float16 대신 float32 사용
    device_map="auto"
)

print(f"어댑터 '{adapter_model_id}'를 베이스 모델에 적용합니다...")
# 그 다음, PEFT 모델(어댑터)을 베이스 모델 위에 덧입힙니다.
model = PeftModel.from_pretrained(base_model, adapter_model_id, token=HF_TOKEN)

# 텍스트 생성을 위한 파이프라인 생성
pipe = pipeline(
    "text-generation",
    model=model,
    tokenizer=tokenizer,
    max_new_tokens=512
)

print("모델 로드 및 파이프라인 생성 완료!")

# --- 3. FastAPI 앱 생성 및 API 엔드포인트 정의 ---
app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "패션 추천 AI 서버가 정상적으로 동작하고 있습니다."}

@app.post("/recommend", response_model=RecommendResponse)
def get_recommendation(request: RecommendRequest):
    """
    사용자의 옷장, 날씨, 일정 정보를 받아 패션 코디를 추천합니다.
    """
    closet_str = ", ".join(request.closet)
    instruction = (
        f"옷장: [{closet_str}]. "
        f"상황: 날씨 '{request.weather}', 일정 '{request.schedule}'. "
        "요청: 이 상황에 가장 잘 어울리는 옷 조합을 추천해 줘."
    )
    prompt = f"<s>[INST] {instruction} [/INST]"

    print(f"\n추론 시작... 프롬프트: {prompt}")
    outputs = pipe(prompt)
    generated_text = outputs[0]['generated_text']
    print(f"추론 결과 (전체): {generated_text}")

    try:
        recommendation_part = generated_text.split("[/INST]")[1].strip()
        if recommendation_part.startswith("추천:"):
            recommendation_part = recommendation_part.replace("추천:", "", 1).strip()
    except IndexError:
        recommendation_part = "추천 결과를 생성하는 데 실패했습니다."

    print(f"추출된 추천 내용: {recommendation_part}")
    
    return RecommendResponse(recommendation=recommendation_part)

# --- 4. 서버 실행 (로컬에서 테스트 시) ---
if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
