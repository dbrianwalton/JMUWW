
=head1 PGjmu_graders.pl DESCRIPTION

Grader Plug-ins

=cut

=head3 mult_choice_reduce_problem_grader

=pod

 ###########################################################
 #    mult_choice_reduce_problem_grader
 #    If the final answer is correct, then the problem is given full credit
 #    and a message is generated to that effect.  Otherwise, partial credit 
 #    is given for previous parts.

=cut

sub mult_choice_reduce_problem_grader {
    my $rh_evaluated_answers = shift;
    my $rh_problem_state = shift;
    my %form_options = @_;

    my %evaluated_answers = %{$rh_evaluated_answers};
        #  The hash $rh_evaluated_answers typically contains: 
        #      'answer1' => 34, 'answer2'=> 'Mozart', etc.
       
    # By default the  old problem state is simply passed back out again.
    my %problem_state = %$rh_problem_state;
        
        
        # %form_options might include
        # The user login name 
        # The permission level of the user
        # The studentLogin name for this psvn.
        # Whether the form is asking for a refresh or
        #     is submitting a new answer.
        
    # initial setup of the answer
    my      $total=0; 

    my %problem_result = ( score => 0,
                errors => '',
                type => 'custom_problem_grader',
                msg => 'Each incorrect attempt reduces the maximum possible score by 25%.',
            );


    # Return unless answers have been submitted
    #  Unsure what this is for, since always seems true.
    unless ($form_options{answers_submitted} == 1) {
    
    # Since this code is in a .pg file we must use double tildes 
    # instead of Perl's backslash on the next line.
        return(\%problem_result,\%problem_state);
    }

    # Answers have been submitted -- process them.
        
    ########################################################
    # Here's where we compute the score.  The variable     #
    # $numright is the number of correct answers.          #
    ########################################################

    # Evaluate the input using the "standard problem grader"
    my ($rh_problem_result, $rh_new_problem_state) =
            std_problem_grader($rh_evaluated_answers,$rh_problem_state,%form_options);

    $total = $rh_problem_result->{score};
    $weight = (4-$envir{'numOfAttempts'})/4;

    $problem_result{score} = $total*$weight; 
        # increase recorded score if the current score is greater.
    $problem_state{recorded_score} = $problem_result{score} if $problem_result{score} > $problem_state{recorded_score};
        
    $problem_state{num_of_correct_ans}++ if $total == 1;
    $problem_state{num_of_incorrect_ans}++ if $total < 1 ;
        
        # Since this code is in a .pg file we must use double tildes 
    # instead of Perl's backslash on the next line.
    (\%problem_result, \%problem_state);

}
