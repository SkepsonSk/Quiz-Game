public with sharing class QuizPickerController {

    @AuraEnabled (Cacheable = true)
    public static List<Question__c> getQuestions(Id quizId){
        List<Question__c> questions = [
            SELECT Question_Content__c,
                   (SELECT Answer_Content__c, Question__c FROM Answers__r)  
            FROM Question__c
            WHERE Quiz__c = :quizId
        ];

        //TODO shuffle

        return questions;
    }
    
    @AuraEnabled
    public static Wrappers.QuizResult finishQuiz(List<Wrappers.QuestionResponse> questionResponses, Id quizId) {
        QuizAnalyzer analyzer = new QuizAnalyzer(questionResponses, quizId);
        analyzer.populateCache();
        Wrappers.QuizResult quizResult = analyzer.process();

        Id userId = UserInfo.getUserId();

        Quiz_Result__c result = getQuizResult(userId, quizId);
        if (result == null) {
            result = new Quiz_Result__c(
                Quiz__c = quizId,
                User__c = UserInfo.getUserId(),
                Points__c = quizResult.points
            );
            insert result;
        }
        else if (quizResult.points > result.Points__c) {
            result.Points__c = quizResult.points;
            update result;
        }

        return quizResult;
    }

    private static Quiz_Result__c getQuizResult(Id userId, Id quizId) {
        List<Quiz_Result__c> result = [
            SELECT Points__c
            FROM Quiz_Result__c
            WHERE User__c = :userId AND Quiz__c = :quizId
        ];

        return result.isEmpty() ? null : result.get(0);
    }

}
