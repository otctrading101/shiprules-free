# Project instructions: Unity 6 (ShipRules free starter)

## Unity 6 API correctness
Use the Unity 6 API, not older tutorials:
- `FindObjectOfType<T>()` is obsolete -> `FindFirstObjectByType<T>()` or faster `FindAnyObjectByType<T>()`.
- `FindObjectsOfType<T>()` is obsolete -> `FindObjectsByType<T>(FindObjectsSortMode.None)`.
- `Rigidbody.velocity` / `Rigidbody2D.velocity` -> `linearVelocity`; `drag` -> `linearDamping`; `angularDrag` -> `angularDamping`. (`NavMeshAgent.velocity` and `CharacterController.velocity` are still valid.)
- Input: if the project uses the Input System package (`com.unity.inputsystem`), use `InputAction`/`PlayerInput`, not `Input.GetKey`/`Input.GetAxis`. Check Player Settings > Active Input Handling before choosing.
- UI text: use TextMeshPro (`TMP_Text`), not legacy `UnityEngine.UI.Text`.
- Prefer `Awaitable` over custom async helpers; `Object.InstantiateAsync` exists for heavy instantiation.
- If unsure an API exists in this Unity version, say so instead of inventing it.

## Null safety
- Every `[SerializeField]` reference must be validated: `[RequireComponent]` for same-object components, or a check in `Awake`/`OnValidate` that logs a clear error with context (`Debug.LogError($"{name}: _target not assigned", this)`) and disables the component.
- Do NOT use `?.`, `??`, `??=`, or `is null` on `UnityEngine.Object` types. They bypass Unity's destroyed-object check. Use `== null` / `if (obj)`.
- `GetComponent` may return null; prefer `TryGetComponent(out T c)`.
- After `await`/coroutine yields, re-check `this` and targets are not destroyed before using them.

---
Free ShipRules starter rules (MIT). Full pack with more rules, a scanner, hooks and a checklist: https://otctrader.gumroad.com/l/pegmfk
