#!/bin/zsh
# Checks the reward, settings and onboarding rules without Xcode. Run from anywhere:
#   zsh scripts/rule-tests/run.sh
set -e
cd "$(dirname "$0")/../.."
out="$(mktemp -d)"
models=(
  Asphyr/Models/Quests/Quest.swift Asphyr/Models/Quests/QuestStore.swift Asphyr/Models/Quests/QuestRecords.swift
  Asphyr/Models/Quests/RewardRules.swift Asphyr/Models/Quests/DailyQuests.swift
  Asphyr/Models/Quests/DifficultyEstimator.swift Asphyr/Models/Profile/UserAttribute.swift
  Asphyr/Models/Profile/Achievement.swift Asphyr/Models/Profile/Archetype.swift
  Asphyr/Models/Journey/JourneyPath.swift Asphyr/Models/Journey/JourneyChapterStars.swift
  Asphyr/Models/Journey/ConstellationData.swift
)
swiftc -D DEBUG -suppress-warnings -o "$out/rewards" $models scripts/rule-tests/rewards/main.swift
swiftc -D DEBUG -suppress-warnings -o "$out/settings" $models \
  Asphyr/Models/Settings/AppSettings.swift Asphyr/Models/Profile/OnboardingProfile.swift \
  Asphyr/Models/Profile/CharacterColor.swift Asphyr/DesignSystem/AppColors.swift \
  scripts/rule-tests/settings/main.swift
echo "--- rewards"; "$out/rewards"
echo "--- settings"; "$out/settings"
