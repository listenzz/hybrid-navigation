package com.navigationhybrid;

import android.support.annotation.AnimRes;

/**
 * Created by Listen on 2017/11/20.
 */

public enum PresentAnimation {

    Push(R.anim.push_fragment_enter, R.anim.push_fragment_exit, R.anim.pop_fragment_enter, R.anim.pop_fragment_exit),
    Modal(R.anim.present_fragment_enter, R.anim.present_fragment_exit, R.anim.dismiss_fragment_enter, R.anim.dismiss_fragment_exit),
    None(R.anim.no_anim, R.anim.no_anim, R.anim.no_anim, R.anim.no_anim);

    @AnimRes int enter;
    @AnimRes int exit;
    @AnimRes int popEnter;
    @AnimRes int popExit;

    PresentAnimation(int enter, int exit, int popEnter, int popExit) {
        this.enter = enter;
        this.exit = exit;
        this.popEnter = popEnter;
        this.popExit = popExit;
    }

}
