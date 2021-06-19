package com.reactnative.hybridnavigation;

import android.os.Bundle;
import android.os.Parcelable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.JavaOnlyArray;
import com.facebook.react.bridge.JavaOnlyMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@SuppressWarnings({"rawtypes", "unchecked"})
public class Parameters {

    @NonNull
    static Bundle mergeOptions(@NonNull Bundle target, @Nullable Bundle source) {
        if (source == null) {
            return target;
        }
        return toBundle(mergeMap(fromBundle(target), fromBundle(source)));
    }

    @NonNull
    static ReadableMap mergeMap(@NonNull ReadableMap target, @NonNull ReadableMap source) {
        WritableMap writableMap = new JavaOnlyMap();
        writableMap.merge(target);

        ReadableMapKeySetIterator it = source.keySetIterator();
        while (it.hasNextKey()) {
            String key = it.nextKey();
            ReadableType type = source.getType(key);
            switch (type) {
                case Array:
                    ReadableArray targetArray = target.getArray(key);
                    ReadableArray sourceArray = source.getArray(key);
                    if (targetArray == null) {
                        writableMap.putArray(key, source.getArray(key));
                    } else if (sourceArray != null) {
                        if (sourceArray.size() != targetArray.size()) {
                            writableMap.putArray(key, sourceArray);
                        } else {
                            writableMap.putArray(key, mergeArray(targetArray, sourceArray));
                        }
                    }
                    break;
                case Map:
                    ReadableMap targetMap = target.getMap(key);
                    ReadableMap sourceMap = source.getMap(key);
                    if (targetMap == null) {
                        writableMap.putMap(key, sourceMap);
                    } else if (sourceMap != null) {
                        writableMap.putMap(key, mergeMap(targetMap, sourceMap));
                    }
                    break;
                case Number:
                    writableMap.putDouble(key, source.getDouble(key));
                    break;
                case String:
                    writableMap.putString(key, source.getString(key));
                    break;
                case Boolean:
                    writableMap.putBoolean(key, source.getBoolean(key));
                    break;
                case Null:
                    writableMap.putNull(key);
                    break;
            }
        }

        return writableMap;
    }

    @NonNull
    static ReadableArray mergeArray(@NonNull ReadableArray target, @NonNull ReadableArray source) {
        // 假设 array 里面的元素是 map
        WritableArray writableArray = new JavaOnlyArray();
        for (int i = 0; i < source.size(); i++) {
            if (source.getType(i) != ReadableType.Map) {
                throw new RuntimeException("The element in array must a map.");
            }
            writableArray.pushMap(mergeMap(target.getMap(i), source.getMap(i)));
        }
        return writableArray;
    }

    @NonNull
    public static WritableMap fromBundle(@NonNull Bundle bundle) {
        WritableMap map = new JavaOnlyMap();
        for (String key : bundle.keySet()) {
            Object value = bundle.get(key);
            if (value == null) {
                map.putNull(key);
            } else if (value.getClass().isArray()) {
                map.putArray(key, fromArray(value));
            } else if (value instanceof String) {
                map.putString(key, (String) value);
            } else if (value instanceof Number) {
                if (value instanceof Integer) {
                    map.putInt(key, (Integer) value);
                } else {
                    map.putDouble(key, ((Number) value).doubleValue());
                }
            } else if (value instanceof Boolean) {
                map.putBoolean(key, (Boolean) value);
            } else if (value instanceof Bundle) {
                map.putMap(key, fromBundle((Bundle) value));
            } else if (value instanceof List) {
                map.putArray(key, fromList((List) value));
            } else {
                throw new IllegalArgumentException("Could not convert " + value.getClass());
            }
        }
        return map;
    }

    @NonNull
    public static WritableArray fromArray(@NonNull Object array) {
        WritableArray catalystArray = new JavaOnlyArray();
        if (array instanceof String[]) {
            for (String v : (String[]) array) {
                catalystArray.pushString(v);
            }
        } else if (array instanceof Bundle[]) {
            for (Bundle v : (Bundle[]) array) {
                catalystArray.pushMap(fromBundle(v));
            }
        } else if (array instanceof int[]) {
            for (int v : (int[]) array) {
                catalystArray.pushInt(v);
            }
        } else if (array instanceof float[]) {
            for (float v : (float[]) array) {
                catalystArray.pushDouble(v);
            }
        } else if (array instanceof double[]) {
            for (double v : (double[]) array) {
                catalystArray.pushDouble(v);
            }
        } else if (array instanceof boolean[]) {
            for (boolean v : (boolean[]) array) {
                catalystArray.pushBoolean(v);
            }
        } else if (array instanceof Parcelable[]) {
            for (Parcelable v : (Parcelable[]) array) {
                if (v instanceof Bundle) {
                    catalystArray.pushMap(fromBundle((Bundle) v));
                } else {
                    throw new IllegalArgumentException("Unexpected array member type " + v.getClass());
                }
            }
        } else {
            throw new IllegalArgumentException("Unknown array type " + array.getClass());
        }
        return catalystArray;
    }

    @NonNull
    public static WritableArray fromList(@NonNull List list) {
        WritableArray catalystArray = new JavaOnlyArray();
        for (Object obj : list) {
            if (obj == null) {
                catalystArray.pushNull();
            } else if (obj.getClass().isArray()) {
                catalystArray.pushArray(fromArray(obj));
            } else if (obj instanceof Bundle) {
                catalystArray.pushMap(fromBundle((Bundle) obj));
            } else if (obj instanceof List) {
                catalystArray.pushArray(fromList((List) obj));
            } else if (obj instanceof String) {
                catalystArray.pushString((String) obj);
            } else if (obj instanceof Integer) {
                catalystArray.pushInt((Integer) obj);
            } else if (obj instanceof Number) {
                catalystArray.pushDouble(((Number) obj).doubleValue());
            } else if (obj instanceof Boolean) {
                catalystArray.pushBoolean((Boolean) obj);
            } else {
                throw new IllegalArgumentException("Unknown value type " + obj.getClass());
            }
        }
        return catalystArray;
    }

    @NonNull
    public static Bundle toBundle(@NonNull ReadableMap readableMap) {
        ReadableMapKeySetIterator iterator = readableMap.keySetIterator();

        Bundle bundle = new Bundle();
        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            ReadableType readableType = readableMap.getType(key);
            switch (readableType) {
                case Null:
                    bundle.putString(key, null);
                    break;
                case Boolean:
                    bundle.putBoolean(key, readableMap.getBoolean(key));
                    break;
                case Number:
                    // Can be int or double.
                    bundle.putDouble(key, readableMap.getDouble(key));
                    break;
                case String:
                    bundle.putString(key, readableMap.getString(key));
                    break;
                case Map:
                    bundle.putBundle(key, toBundle(Objects.requireNonNull(readableMap.getMap(key))));
                    break;
                case Array:
                    bundle.putSerializable(key, toList(Objects.requireNonNull(readableMap.getArray(key))));
                    break;
                default:
                    throw new IllegalArgumentException("Could not convert object with key: " + key + ".");
            }
        }

        return bundle;
    }

    @NonNull
    public static ArrayList toList(@NonNull ReadableArray readableArray) {
        ArrayList list = new ArrayList();

        for (int i = 0; i < readableArray.size(); i++) {
            switch (readableArray.getType(i)) {
                case Null:
                    list.add(null);
                    break;
                case Boolean:
                    list.add(readableArray.getBoolean(i));
                    break;
                case Number:
                    double number = readableArray.getDouble(i);
                    if (number == Math.rint(number)) {
                        // Add as an integer
                        list.add((int) number);
                    } else {
                        // Add as a double
                        list.add(number);
                    }
                    break;
                case String:
                    list.add(readableArray.getString(i));
                    break;
                case Map:
                    list.add(toBundle(readableArray.getMap(i)));
                    break;
                case Array:
                    list.add(toList(readableArray.getArray(i)));
                    break;
                default:
                    throw new IllegalArgumentException("Could not convert object in array.");
            }
        }

        return list;
    }
}
