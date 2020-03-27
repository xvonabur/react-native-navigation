package com.reactnativenavigation.viewcontrollers;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ImageButton;
import android.widget.TextView;

import com.reactnativenavigation.parse.Options;
import com.reactnativenavigation.parse.params.Button;
import com.reactnativenavigation.parse.params.Text;
import com.reactnativenavigation.react.events.ComponentType;
import com.reactnativenavigation.utils.ArrayUtils;
import com.reactnativenavigation.utils.ButtonPresenter;
import com.reactnativenavigation.utils.ImageLoader;
import com.reactnativenavigation.utils.ImageLoadingListenerAdapter;
import com.reactnativenavigation.utils.UiUtils;
import com.reactnativenavigation.utils.ViewUtils;
import com.reactnativenavigation.viewcontrollers.button.IconResolver;
import com.reactnativenavigation.viewcontrollers.viewcontrolleroverlay.ViewControllerOverlay;
import com.reactnativenavigation.views.titlebar.TitleBarReactButtonView;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.RestrictTo;
import androidx.appcompat.widget.ActionMenuView;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.MenuItemCompat;

public class TitleBarButtonController extends ViewController<TitleBarReactButtonView> implements MenuItem.OnMenuItemClickListener {
    public interface OnClickListener {
        void onPress(String buttonId);
    }

    private final IconResolver navigationIconResolver;
    private ButtonPresenter optionsPresenter;
    private final Button button;
    private final ReactViewCreator viewCreator;
    private TitleBarButtonController.OnClickListener onPressListener;
    private Drawable icon;

    @RestrictTo(RestrictTo.Scope.TESTS)
    public Button getButton() {
        return button;
    }

    public String getButtonInstanceId() {
        return button.instanceId;
    }

    public TitleBarButtonController(Activity activity,
                                    IconResolver navigationIconResolver,
                                    ButtonPresenter optionsPresenter,
                                    Button button,
                                    ReactViewCreator viewCreator,
                                    OnClickListener onClickListener) {
        super(activity, button.id, new YellowBoxDelegate(), new Options(), new ViewControllerOverlay(activity));
        this.navigationIconResolver = navigationIconResolver;
        this.optionsPresenter = optionsPresenter;
        this.button = button;
        this.viewCreator = viewCreator;
        this.onPressListener = onClickListener;
    }

    @SuppressLint("MissingSuperCall")
    @Override
    public void onViewAppeared() {
        getView().sendComponentStart(ComponentType.Button);
    }

    @SuppressLint("MissingSuperCall")
    @Override
    public void onViewDisappear() {
        getView().sendComponentStop(ComponentType.Button);
    }

    @Override
    public boolean isRendered() {
        return !button.component.componentId.hasValue() || super.isRendered();
    }

    @Override
    public void sendOnNavigationButtonPressed(String buttonId) {
        getView().sendOnNavigationButtonPressed(buttonId);
    }

    @Override
    public String getCurrentComponentName() {
        return button.component.name.get();
    }

    @NonNull
    @Override
    protected TitleBarReactButtonView createView() {
        view = (TitleBarReactButtonView) viewCreator.create(getActivity(), button.component.componentId.get(), button.component.name.get());
        return (TitleBarReactButtonView) view.asView();
    }

    @Override
    public boolean onMenuItemClick(MenuItem item) {
        onPressListener.onPress(button.id);
        return true;
    }

    public void applyNavigationIcon(Toolbar toolbar) {
        navigationIconResolver.resolve(button, icon -> {
            setIconColor(icon);
            toolbar.setNavigationOnClickListener(view -> onPressListener.onPress(button.id));
            toolbar.setNavigationIcon(icon);
            setLeftButtonTestId(toolbar);
            if (button.accessibilityLabel.hasValue()) toolbar.setNavigationContentDescription(button.accessibilityLabel.get());
        });
    }

    private void setLeftButtonTestId(Toolbar toolbar) {
        if (!button.testId.hasValue()) return;
        toolbar.post(() -> {
            ImageButton leftButton = ViewUtils.findChildByClass(toolbar, ImageButton.class);
            if (leftButton != null) {
                leftButton.setTag(button.testId.get());
            }
        });
    }

    public void addToMenu(Toolbar toolbar, int position) {
        MenuItem menuItem = toolbar.getMenu().add(Menu.NONE, position, position, button.text.get(""));
        if (button.showAsAction.hasValue()) menuItem.setShowAsAction(button.showAsAction.get());
        menuItem.setEnabled(button.enabled.isTrueOrUndefined());
        menuItem.setOnMenuItemClickListener(this);
        if (button.hasComponent()) {
            menuItem.setActionView(getView());
            if (button.accessibilityLabel.hasValue()) getView().setContentDescription(button.accessibilityLabel.get());
        } else {
            if (button.accessibilityLabel.hasValue()) MenuItemCompat.setContentDescription(menuItem, button.accessibilityLabel.get());
            if (button.hasIcon()) {
                loadIcon(new ImageLoadingListenerAdapter() {
                    @Override
                    public void onComplete(@NonNull Drawable icon) {
                        TitleBarButtonController.this.icon = icon;
                        setIconColor(icon);
                        menuItem.setIcon(icon);
                    }
                });
            } else {
                optionsPresenter.setTextColor();
                if (button.fontSize.hasValue()) optionsPresenter.setFontSize(menuItem);
                optionsPresenter.setTypeFace(button.fontFamily);
            }
        }
        setTestId(toolbar, button.testId);
    }

    private void loadIcon(ImageLoader.ImagesLoadingListener callback) {
        navigationIconResolver.resolve(button, callback::onComplete);
    }

    private void setIconColor(Drawable icon) {
        if (button.disableIconTint.isTrue()) return;
        if (button.enabled.isTrueOrUndefined() && button.color.hasValue()) {
            optionsPresenter.tint(icon, button.color.get());
        } else if (button.enabled.isFalse()) {
            optionsPresenter.tint(icon, button.disabledColor.get(Color.LTGRAY));
        }
    }

    private void setTestId(Toolbar toolbar, Text testId) {
        if (!testId.hasValue()) return;
        UiUtils.runOnPreDrawOnce(toolbar, () -> {
            if (button.hasComponent() && view != null) {
                view.setTag(testId.get());
            }
            ActionMenuView buttonsLayout = ViewUtils.findChildByClass(toolbar, ActionMenuView.class);
            List<TextView> buttons = ViewUtils.findChildrenByClass(buttonsLayout, TextView.class);
            for (TextView view : buttons) {
                if (button.text.hasValue() && button.text.get().equals(view.getText().toString())) {
                    view.setTag(testId.get());
                } else if (button.icon.hasValue() && ArrayUtils.contains(view.getCompoundDrawables(), icon)) {
                    view.setTag(testId.get());
                }
            }
        });
    }
}
