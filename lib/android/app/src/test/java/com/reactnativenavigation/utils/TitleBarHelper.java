package com.reactnativenavigation.utils;

import android.app.Activity;

import com.reactnativenavigation.mocks.ImageLoaderMock;
import com.reactnativenavigation.mocks.TopBarButtonCreatorMock;
import com.reactnativenavigation.parse.Component;
import com.reactnativenavigation.parse.params.Button;
import com.reactnativenavigation.parse.params.Text;
import com.reactnativenavigation.viewcontrollers.TitleBarButtonController;
import com.reactnativenavigation.viewcontrollers.button.IconResolver;
import com.reactnativenavigation.views.titlebar.TitleBar;

import androidx.appcompat.view.menu.ActionMenuItemView;
import androidx.appcompat.widget.Toolbar;

public class TitleBarHelper {
    public static ActionMenuItemView getRightButton(Toolbar toolbar, int index) {
        return (ActionMenuItemView) ViewUtils.findChildrenByClassRecursive(toolbar, ActionMenuItemView.class).get(toolbar.getMenu().size() - index - 1);
    }

    public static Button textualButton(String text) {
        Button button = new Button();
        button.id = text + CompatUtils.generateViewId();
        button.text = new Text(text);
        return button;
    }

    public static Button reactViewButton(String name) {
        Button button = new Button();
        button.id = name + CompatUtils.generateViewId();
        button.component = new Component();
        button.component.name = new Text("com.example" + name + CompatUtils.generateViewId());
        button.component.componentId = new Text(name + CompatUtils.generateViewId());
        return button;
    }

    public static Component titleComponent(String componentId) {
        Component component = new Component();
        component.componentId = new Text(componentId);
        component.name = new Text(componentId);
        return component;
    }

    public static Button iconButton(String id, String icon) {
        Button button = new Button();
        button.id = "someButton";
        button.icon = new Text(icon);
        return button;
    }


    public static TitleBarButtonController createButtonController(Activity activity, TitleBar titleBar, Button button) {
        return new TitleBarButtonController(activity,
                new IconResolver(activity, ImageLoaderMock.mock()),
                new ButtonPresenter(titleBar, button),
                button,
                new TopBarButtonCreatorMock(),
                buttonId -> {}
        );
    }
}
