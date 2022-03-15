public class Wrappers {

    public class QuestionResponse {
        @AuraEnabled public Id questionId {get; set;}
        @AuraEnabled public Id answerId {get; set;}
        @AuraEnabled public Boolean response {get; set;}
    }

    public class QuizResult {
        @AuraEnabled public Integer points { get; set; }
        @AuraEnabled public Integer maxPoints { get; set; }

        public QuizResult(Integer points, Integer maxPoints) {
            this.points = points;
            this.maxPoints = maxPoints;
        }
    }

}
